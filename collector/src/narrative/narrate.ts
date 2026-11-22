/**
 * StoredRecord[] -> Session. Pure, total and deterministic, re-run from scratch whenever records
 * grow. No incremental state: the stored log stays the single source of truth, and improving this
 * function re-interprets every old session.
 */

import {
	HOSTS,
	screenKey,
	type CardId,
	type DomainRecord,
	type PropValue,
	type ScreenRef,
	type Seq,
	type SessionField,
	type SessionFields,
	type SessionId,
	type StoredRecord,
	type TrackedEvent,
} from "../model";
import { parseRecord } from "../wire";
import { checkEvent, finding, type Finding, type FindingCode } from "./findings";
import type {
	Arrival,
	EventCard,
	FieldChange,
	MalformedRecord,
	Presentation,
	Reply,
	Session,
	SessionContext,
	StreamItem,
	Visit,
} from "./types";

const HOST_SET = new Set<string>(HOSTS);

type Ordered =
	| { kind: "event"; seq: Seq; line: number; receivedAt: string; raw: unknown; event: TrackedEvent; unknownKeys: string[]; id: CardId }
	| { kind: "update"; seq: Seq; line: number; record: Extract<DomainRecord, { kind: "session_update" }> };

type Pending =
	| { kind: "navigates"; target: ScreenRef | "previous"; card: EventCard; reply: Extract<Reply, { kind: "jump" }> }
	| { kind: "tab"; card: EventCard };

export function narrate(records: readonly StoredRecord[], sessionId: string): Session {
	const findings: Finding[] = [];
	const cardFindings: Array<{ id: CardId; code: FindingCode; detail: string; seq: Seq }> = [];
	const flag = (code: FindingCode, at: { card: CardId | null; seq: Seq | null }, detail: string) => {
		findings.push(finding(code, at, detail));
	};

	// 1. Parse at the boundary.
	const malformed: MalformedRecord[] = [];
	const inits: Array<{ line: number; record: Extract<DomainRecord, { kind: "session_init" }> }> = [];
	const raw: Ordered[] = [];
	for (const stored of records) {
		const parsed = parseRecord(stored);
		if (!parsed.ok) {
			malformed.push({ line: stored.line, receivedAt: stored.receivedAt, reason: parsed.reason, raw: stored.body });
			flag("malformed", { card: null, seq: null }, `line ${stored.line}: ${parsed.reason}`);
			continue;
		}
		const r = parsed.record;
		if (r.kind === "session_init") inits.push({ line: stored.line, record: r });
		else if (r.kind === "session_update") raw.push({ kind: "update", seq: r.seq, line: stored.line, record: r });
		else
			raw.push({
				kind: "event",
				seq: r.event.seq,
				line: stored.line,
				receivedAt: stored.receivedAt,
				raw: stored.body,
				event: r.event,
				unknownKeys: parsed.unknownKeys,
				id: String(r.event.seq) as CardId,
			});
	}

	// 2. Session init.
	const init = inits[0]?.record ?? null;
	if (!inits.length) flag("missing_init", { card: null, seq: null }, "no session_init received; showing events only");
	if (inits.length > 1) flag("duplicate_init", { card: null, seq: null }, `${inits.length} session_init records; the first wins`);
	const firstEventLine = Math.min(...raw.map((r) => r.line));
	if (inits[0] && inits[0].line > firstEventLine) {
		flag("init_not_first", { card: null, seq: null }, `session_init is line ${inits[0].line}, events start at line ${firstEventLine}`);
	}

	// 3. Order by seq, collapse retries, keep conflicts.
	raw.sort((a, b) => a.seq - b.seq || a.line - b.line);
	const ordered: Ordered[] = [];
	const firstBody = new Map<number, string>();
	let maxSeq = 0;
	let maxLine = -1;
	for (const r of raw) {
		const body = JSON.stringify(r.kind === "event" ? r.raw : records.find((s) => s.line === r.line)?.body);
		const seen = firstBody.get(r.seq);
		if (seen !== undefined) {
			if (seen === body) {
				flag("seq_retry", { card: null, seq: r.seq }, `#${r.seq} received again (line ${r.line})`);
				continue;
			}
			if (r.kind === "event") {
				r.id = `${r.seq}~${r.line}` as CardId;
				cardFindings.push({ id: r.id, code: "seq_conflict", seq: r.seq, detail: `#${r.seq} has a different body on line ${r.line}` });
			} else {
				flag("seq_conflict", { card: null, seq: r.seq }, `#${r.seq} has a different body on line ${r.line}`);
			}
		} else {
			firstBody.set(r.seq, body);
			if (r.seq > maxSeq + 1) {
				const detail = maxSeq === 0 ? `seq starts at ${r.seq}` : `missing ${maxSeq + 1}${r.seq - 1 > maxSeq + 1 ? `..${r.seq - 1}` : ""}`;
				flag("seq_gap", { card: null, seq: r.seq }, detail);
			}
			maxSeq = Math.max(maxSeq, r.seq);
		}
		if (r.line < maxLine && r.kind === "event") {
			cardFindings.push({ id: r.id, code: "late_arrival", seq: r.seq, detail: `line ${r.line} arrived after line ${maxLine}` });
		}
		maxLine = Math.max(maxLine, r.line);
		ordered.push(r);
	}

	// 4. Fold into visits, threads and replies.
	const context: SessionContext = {
		init: init ? { startedAt: init.startedAt, fields: init.fields } : null,
		changes: [],
		current: init ? { ...init.fields } : null,
	};
	const folded: Partial<Record<SessionField, PropValue>> = init
		? { currency: init.fields.currency, notifications_enabled: init.fields.notifications_enabled, launch_root: init.fields.launch_root }
		: {};

	const visits: Visit[] = [];
	const cards: EventCard[] = [];
	let cur: Visit | null = null;
	let stack: Presentation[] = [];
	let pending: Pending | null = null;
	let back: ScreenRef[] = [];
	let presentations = 0;
	const firstEvent = ordered.find((o) => o.kind === "event");
	const startAt = init?.startedAt ?? (firstEvent?.kind === "event" ? firstEvent.event.at : null);
	let prevAt: Date | null = null;

	const closeAll = () => {
		for (const p of stack) {
			if (!p.items.length && p.openedBy) {
				cardFindings.push({ id: p.openedBy, code: "empty_presentation", seq: Number(p.openedBy.split("~")[0]) as Seq, detail: `${p.name} logged no events` });
			}
		}
		stack = [];
	};
	const innermost = (): StreamItem[] | null => stack[stack.length - 1]?.items ?? cur?.items ?? null;

	for (const o of ordered) {
		if (o.kind === "update") {
			const { field, value, seq, at } = o.record;
			const from = folded[field] ?? null;
			if (from === value) flag("noop_update", { card: null, seq }, `${field} is already ${JSON.stringify(value)}`);
			const change: FieldChange = { seq, at, field, from, to: value };
			context.changes.push(change);
			folded[field] = value;
			if (context.current) context.current = { ...context.current, [field]: value } as SessionFields;
			innermost()?.push({ kind: "context", change });
			continue;
		}

		const e = o.event;
		const here: ScreenRef = { layer: e.layer, screen: e.screen };
		const card: EventCard = {
			id: o.id,
			event: e,
			path: [e.layer, e.screen, e.component, e.element].filter((x): x is string => x !== null).join("."),
			visit: 0,
			chain: [],
			sincePrevMs: prevAt ? e.at.getTime() - prevAt.getTime() : null,
			sinceStartMs: startAt ? e.at.getTime() - startAt.getTime() : null,
			findings: [],
			receivedAt: o.receivedAt,
			line: o.line,
			raw: o.raw,
		};
		prevAt = e.at;
		cards.push(card);
		const at = { card: card.id, seq: e.seq };
		for (const [code, detail] of checkEvent(e)) cardFindings.push({ id: card.id, code, seq: e.seq, detail });
		for (const key of o.unknownKeys) cardFindings.push({ id: card.id, code: "unknown_field", seq: e.seq, detail: `top-level "${key}"` });

		// a) Visit boundary: a screen-owned event on a new screen.
		if (cur === null || (e.owner === "screen" && screenKey(here) !== screenKey(cur.screen))) {
			let arrival: Arrival;
			if (cur === null) {
				arrival = { kind: "launch" };
				back = [];
			} else if (pending?.kind === "navigates") {
				const popped = pending.target === "previous";
				const expected = popped ? (back[back.length - 1] ?? null) : (pending.target as ScreenRef);
				const fulfilled = expected === null || screenKey(expected) === screenKey(here);
				pending.reply.fulfilled = fulfilled;
				pending.reply.toVisit = visits.length;
				if (!fulfilled) {
					cardFindings.push({ id: pending.card.id, code: "unfulfilled_navigation", seq: pending.card.event.seq, detail: `expected ${screenKey(expected!)}, got ${screenKey(here)} (#${e.seq})` });
				}
				arrival = { kind: popped ? "popped" : "navigated", via: pending.card.id, fromVisit: cur.index };
				if (popped) back.pop();
				else back.push(cur.screen);
			} else if (pending?.kind === "tab") {
				arrival = { kind: "tab", via: pending.card.id };
				back = [];
			} else {
				arrival = { kind: "unexplained" };
				cardFindings.push({ id: card.id, code: "unexplained_arrival", seq: e.seq, detail: `${screenKey(cur.screen)} → ${screenKey(here)} without navigates or tab` });
				back.push(cur.screen);
			}
			closeAll();
			cur = { index: visits.length, screen: here, arrival, startedAt: e.at, items: [] };
			visits.push(cur);
			pending = null;
		} else if (e.owner === "screen" && pending?.kind === "navigates") {
			const target = pending.target === "previous" ? "previous" : screenKey(pending.target);
			pending.reply.fulfilled = false;
			cardFindings.push({ id: pending.card.id, code: "unfulfilled_navigation", seq: pending.card.event.seq, detail: `expected ${target}, still on ${screenKey(here)} (#${e.seq})` });
			pending = null;
		} else if (e.owner === "screen" && pending?.kind === "tab") {
			pending = null;
		}
		const visit: Visit = cur;
		if (e.owner === "shell" && screenKey(here) !== screenKey(visit.screen)) {
			cardFindings.push({ id: card.id, code: "shell_screen_mismatch", seq: e.seq, detail: `reports ${screenKey(here)}, current screen is ${screenKey(visit.screen)}` });
		}

		// b) Placement: presentations are components, membership is by component name.
		let container: StreamItem[] = visit.items;
		let depth = 0;
		let hostChecked = false;
		if (e.owner === "screen" && e.component !== null) {
			const i = stack.findLastIndex((p) => p.name === e.component);
			if (i >= 0) {
				stack = stack.slice(0, i + 1);
				container = stack[i]!.items;
				depth = i + 1;
			} else if (e.host !== null) {
				const h = stack.findLastIndex((p) => p.name === e.host);
				if (h >= 0) {
					stack = stack.slice(0, h + 1);
					const implicit: Presentation = { name: e.component, mode: null, openedBy: null, depth: h + 2, items: [] };
					stack[h]!.items.push({ kind: "implicit", presentation: implicit });
					stack.push(implicit);
					presentations++;
					container = implicit.items;
					depth = h + 2;
					cardFindings.push({ id: card.id, code: "implicit_presentation", seq: e.seq, detail: `${e.component} opened inside ${e.host} without presents` });
				} else {
					cardFindings.push({ id: card.id, code: "host_mismatch", seq: e.seq, detail: `host ${e.host} is not open` });
					hostChecked = true;
					closeAll();
				}
			} else {
				closeAll();
			}
		} else if (e.owner === "screen") {
			closeAll();
		}

		if (depth >= 1) {
			const parent = depth >= 2 ? stack[depth - 2]!.name : null;
			const expected = parent && HOST_SET.has(parent) ? parent : null;
			if (e.host !== expected) {
				if (expected && e.host === null) cardFindings.push({ id: card.id, code: "missing_host", seq: e.seq, detail: `expected host ${expected}` });
				else cardFindings.push({ id: card.id, code: "host_mismatch", seq: e.seq, detail: `host ${e.host ?? "none"}, expected ${expected ?? "none"}` });
			}
		} else if (e.owner === "screen" && e.host !== null && !hostChecked) {
			cardFindings.push({ id: card.id, code: "host_mismatch", seq: e.seq, detail: `host ${e.host} on a screen-level event` });
		}
		card.visit = visit.index;
		card.chain = stack.slice(0, depth).map((p) => p.name);

		// c) Reply from the effect.
		let reply: Reply | null = null;
		switch (e.effect.kind) {
			case "reroots":
				reply = { kind: "reroot" };
				break;
			case "presents": {
				if (e.owner === "shell") closeAll();
				const p: Presentation = { name: e.effect.presentation, mode: e.effect.mode, openedBy: card.id, depth: stack.length + 1, items: [] };
				stack.push(p);
				presentations++;
				reply = { kind: "thread", presentation: p };
				break;
			}
			case "navigates": {
				const jump: Extract<Reply, { kind: "jump" }> = { kind: "jump", target: e.effect.to, toVisit: null, fulfilled: false };
				reply = jump;
				pending = { kind: "navigates", target: e.effect.to, card, reply: jump };
				break;
			}
		}
		if (e.owner === "shell" && e.element === "tab" && e.interaction === "tap" && pending === null) {
			pending = { kind: "tab", card };
		}

		// d) Append, collapsing consecutive views of the same element.
		const last = container[container.length - 1];
		const key = `${e.component}.${e.element}`;
		const sameView = (c: EventCard) => c.event.interaction === "view" && `${c.event.component}.${c.event.element}` === key;
		if (e.interaction === "view" && e.element !== null && reply === null && last?.kind === "card" && last.reply === null && sameView(last.card)) {
			container[container.length - 1] = { kind: "views", cards: [last.card, card] };
		} else if (e.interaction === "view" && e.element !== null && reply === null && last?.kind === "views" && sameView(last.cards[0]!)) {
			last.cards.push(card);
		} else {
			container.push({ kind: "card", card, reply });
		}
	}

	// 5. End of session.
	if (pending?.kind === "navigates") {
		const target = pending.target === "previous" ? "previous" : screenKey(pending.target);
		cardFindings.push({ id: pending.card.id, code: "unfulfilled_navigation", seq: pending.card.event.seq, detail: `session ended before ${target} appeared` });
	}
	closeAll();

	// 6. Attach findings and compute stats.
	const byId = new Map(cards.map((c) => [c.id, c]));
	for (const f of cardFindings) {
		const made = finding(f.code, { card: f.id, seq: f.seq }, f.detail);
		findings.push(made);
		byId.get(f.id)?.findings.push(made);
	}
	findings.sort((a, b) => (a.seq ?? 0) - (b.seq ?? 0));

	const lastCard = cards[cards.length - 1];
	return {
		id: sessionId as SessionId,
		source: records[0]?.source ?? "unknown",
		context,
		visits,
		cards,
		malformed,
		findings,
		stats: {
			durationMs: lastCard && startAt ? lastCard.event.at.getTime() - startAt.getTime() : null,
			events: cards.length,
			visits: visits.length,
			screens: new Set(visits.map((v) => screenKey(v.screen))).size,
			presentations,
			findings: {
				error: findings.filter((f) => f.severity === "error").length,
				warn: findings.filter((f) => f.severity === "warn").length,
				info: findings.filter((f) => f.severity === "info").length,
			},
		},
	};
}

/** Session fields as they were when `seq` happened. */
export function contextAt(context: SessionContext, seq: Seq): SessionFields | null {
	if (!context.init) return null;
	let fields: SessionFields = { ...context.init.fields };
	for (const change of context.changes) {
		if (change.seq < seq) fields = { ...fields, [change.field]: change.to } as SessionFields;
	}
	return fields;
}
