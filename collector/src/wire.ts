/**
 * The only module that knows the JSON the app POSTs. Validates the envelope and the closed sets
 * the narrative depends on; taxonomy values (layer, screen, element ids, prop names) stay opaque.
 */

import {
	INTERACTIONS,
	OWNERS,
	RECORD_KINDS,
	SESSION_FIELDS,
	SESSION_INIT_FIELDS,
	type DomainRecord,
	type Effect,
	type PropValue,
	type ScreenRef,
	type Seq,
	type SessionFields,
	type SessionId,
	type StoredRecord,
} from "./model";

export type WireEffect = "stays" | "reroots" | `navigates(${string})` | `presents(${string})`;

export type WireSessionInit = { kind: "session_init"; session_id: string; started_at: string } & SessionFields;

export interface WireSessionUpdate {
	kind: "session_update";
	session_id: string;
	seq: number;
	timestamp?: string;
	field: (typeof SESSION_FIELDS)[number];
	value: string | boolean;
}

export interface WireEvent {
	kind: "event";
	session_id: string;
	seq: number;
	timestamp: string;
	owner: (typeof OWNERS)[number];
	layer: string;
	screen: string;
	component: string | null;
	element: string | null;
	interaction: (typeof INTERACTIONS)[number];
	effect: WireEffect;
	domain: string;
	props: Record<string, PropValue>;
	host?: string;
}

export type WireRecord = WireSessionInit | WireSessionUpdate | WireEvent;

export type Parsed =
	| { ok: true; record: DomainRecord; unknownKeys: string[] }
	| { ok: false; reason: string };

const SESSION_ID = /^[A-Za-z0-9_-]{1,64}$/;
const ID = /^[a-z0-9_]+$/;
const ISO = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$/;

const EVENT_KEYS = new Set([
	"kind", "session_id", "seq", "timestamp", "owner", "layer", "screen", "component", "element",
	"interaction", "effect", "domain", "props", "host",
]);
const UPDATE_KEYS = new Set(["kind", "session_id", "seq", "timestamp", "field", "value"]);
const INIT_KEYS = new Set<string>(["kind", "session_id", "started_at", ...SESSION_INIT_FIELDS]);

/** Filename-safe session key. Anything else lands in "_invalid" and is still recorded. */
export function routeKey(body: unknown): string {
	if (isObject(body) && typeof body.session_id === "string" && SESSION_ID.test(body.session_id)) {
		return body.session_id;
	}
	return "_invalid";
}

export function parseRecord(stored: StoredRecord): Parsed {
	const body = stored.body;
	if (!isObject(body)) return fail("record is not a JSON object");
	if (!includes(RECORD_KINDS, body.kind)) return fail(`unknown kind ${JSON.stringify(body.kind)}`);
	if (typeof body.session_id !== "string" || !SESSION_ID.test(body.session_id)) return fail("missing or invalid session_id");
	const sessionId = body.session_id as SessionId;

	switch (body.kind) {
		case "session_init": {
			const startedAt = parseTime(body.started_at);
			if (!startedAt) return fail("started_at is not ISO-8601");
			const missing = SESSION_INIT_FIELDS.filter((k) => !(k in body));
			if (missing.length) return fail(`session_init is missing ${missing.join(", ")}`);
			for (const k of ["notifications_enabled", "reduce_motion"] as const) {
				if (typeof body[k] !== "boolean") return fail(`${k} must be a boolean`);
			}
			const fields = Object.fromEntries(SESSION_INIT_FIELDS.map((k) => [k, body[k]])) as unknown as SessionFields;
			return ok({ kind: "session_init", sessionId, startedAt, fields }, body, INIT_KEYS);
		}
		case "session_update": {
			const seq = parseSeq(body.seq);
			if (seq === null) return fail("seq must be a positive integer");
			if (!includes(SESSION_FIELDS, body.field)) return fail(`unknown session field ${JSON.stringify(body.field)}`);
			if (typeof body.value !== "string" && typeof body.value !== "boolean") return fail("value must be a string or boolean");
			const at = body.timestamp === undefined ? new Date(stored.receivedAt) : parseTime(body.timestamp);
			if (!at) return fail("timestamp is not ISO-8601");
			return ok({ kind: "session_update", sessionId, seq, at, field: body.field, value: body.value }, body, UPDATE_KEYS);
		}
		case "event": {
			const seq = parseSeq(body.seq);
			if (seq === null) return fail("seq must be a positive integer");
			const at = parseTime(body.timestamp);
			if (!at) return fail("timestamp is not ISO-8601");
			if (!includes(OWNERS, body.owner)) return fail(`unknown owner ${JSON.stringify(body.owner)}`);
			if (!includes(INTERACTIONS, body.interaction)) return fail(`unknown interaction ${JSON.stringify(body.interaction)}`);
			for (const k of ["layer", "screen", "domain"] as const) {
				if (typeof body[k] !== "string" || body[k] === "") return fail(`${k} must be a non-empty string`);
			}
			for (const k of ["component", "element"] as const) {
				if (body[k] !== null && typeof body[k] !== "string") return fail(`${k} must be a string or null`);
			}
			if (body.host !== undefined && body.host !== null && typeof body.host !== "string") return fail("host must be a string");
			const effect = typeof body.effect === "string" ? parseEffect(body.effect) : null;
			if (!effect) return fail(`effect ${JSON.stringify(body.effect)} does not match the effect grammar`);
			if (!isObject(body.props)) return fail("props must be an object");
			for (const [k, v] of Object.entries(body.props)) {
				if (typeof v !== "string" && typeof v !== "number" && typeof v !== "boolean") {
					return fail(`prop ${k} must be a string, number or boolean`);
				}
			}
			return ok(
				{
					kind: "event",
					sessionId,
					event: {
						seq,
						at,
						owner: body.owner,
						layer: body.layer as string,
						screen: body.screen as string,
						component: (body.component as string | null) ?? null,
						element: (body.element as string | null) ?? null,
						interaction: body.interaction,
						effect,
						domain: body.domain as string,
						props: body.props as Record<string, PropValue>,
						host: (body.host as string | null | undefined) ?? null,
					},
				},
				body,
				EVENT_KEYS,
			);
		}
	}
}

/** "stays" | "reroots" | "navigates(layer.screen | previous)" | "presents(name[, mode])" */
export function parseEffect(text: string): Effect | null {
	if (text === "stays" || text === "reroots") return { kind: text };
	const nav = /^navigates\((previous|[a-z0-9_]+\.[a-z0-9_]+)\)$/.exec(text);
	if (nav) return { kind: "navigates", to: nav[1] === "previous" ? "previous" : parseScreenRef(nav[1]!)! };
	const pres = /^presents\(([a-z0-9_]+)(?:,\s*([a-z0-9_]+))?\)$/.exec(text);
	if (pres) return { kind: "presents", presentation: pres[1]!, mode: pres[2] ?? null };
	return null;
}

export function parseScreenRef(text: string): ScreenRef | null {
	const [layer, screen, ...rest] = text.split(".");
	if (!layer || !screen || rest.length || !ID.test(layer) || !ID.test(screen)) return null;
	return { layer, screen };
}

function ok(record: DomainRecord, body: Record<string, unknown>, known: Set<string>): Parsed {
	return { ok: true, record, unknownKeys: Object.keys(body).filter((k) => !known.has(k)) };
}

function fail(reason: string): Parsed {
	return { ok: false, reason };
}

function parseSeq(v: unknown): Seq | null {
	return typeof v === "number" && Number.isInteger(v) && v >= 1 ? (v as Seq) : null;
}

function parseTime(v: unknown): Date | null {
	if (typeof v !== "string" || !ISO.test(v)) return null;
	const d = new Date(v);
	return Number.isNaN(d.getTime()) ? null : d;
}

function isObject(v: unknown): v is Record<string, unknown> {
	return typeof v === "object" && v !== null && !Array.isArray(v);
}

function includes<T extends string>(list: readonly T[], v: unknown): v is T {
	return typeof v === "string" && (list as readonly string[]).includes(v);
}
