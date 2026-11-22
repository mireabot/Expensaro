/** The narrative as indented text, for `reflex print` (agents read this from a terminal). */

import { formatEffect, screenKey } from "../model";
import type { Finding } from "./findings";
import type { EventCard, Session, StreamItem } from "./types";

export function renderText(session: Session, opts: { findingsOnly: boolean }): string {
	const out: string[] = [];
	const init = session.context.init?.fields;
	const changes = session.context.changes.map((c) => `${c.field} ${JSON.stringify(c.from)} → ${JSON.stringify(c.to)}`);
	out.push(
		`session ${session.id} · ${session.source}` +
			(init ? ` · iOS ${init.os_version} ${init.device_class} · ${init.app_version} (${init.build})` : " · no session_init") +
			(changes.length ? ` · ${changes.join(", ")}` : ""),
	);
	out.push(`${session.stats.events} events · ${session.stats.visits} visits · findings ${session.stats.findings.error} error, ${session.stats.findings.warn} warn, ${session.stats.findings.info} info`);

	if (!opts.findingsOnly) {
		for (const visit of session.visits) {
			const via = visit.arrival.kind === "navigated" || visit.arrival.kind === "popped" || visit.arrival.kind === "tab" ? ` via #${visit.arrival.via}` : "";
			out.push(`▸ ${screenKey(visit.screen)}  (${visit.arrival.kind}${via})`);
			items(visit.items, "  ", out);
		}
	}
	for (const f of session.findings) out.push(line(f));
	return out.join("\n");
}

function items(list: StreamItem[], indent: string, out: string[]) {
	for (const item of list) {
		switch (item.kind) {
			case "card":
				out.push(`${indent}${card(item.card)}`);
				if (item.reply?.kind === "jump") {
					const target = item.reply.target === "previous" ? "previous" : screenKey(item.reply.target);
					out.push(`${indent}     → navigates ${target} ${item.reply.fulfilled ? "✓" : "✗"}`);
				}
				if (item.reply?.kind === "thread") {
					out.push(`${indent}     ↳ presents ${item.reply.presentation.name}${item.reply.presentation.mode ? ` · ${item.reply.presentation.mode}` : ""}`);
					items(item.reply.presentation.items, `${indent}       `, out);
				}
				break;
			case "views":
				out.push(`${indent}#${item.cards[0]!.event.seq}-${item.cards[item.cards.length - 1]!.event.seq}  view ×${item.cards.length}  ${element(item.cards[0]!)}`);
				break;
			case "context":
				out.push(`${indent}⚙ #${item.change.seq}  ${item.change.field}: ${JSON.stringify(item.change.from)} → ${JSON.stringify(item.change.to)}`);
				break;
			case "implicit":
				out.push(`${indent}↳ ${item.presentation.name} (opened implicitly)`);
				items(item.presentation.items, `${indent}  `, out);
				break;
		}
	}
}

function card(c: EventCard): string {
	const props = Object.entries(c.event.props).map(([k, v]) => `${k}=${v}`).join(" ");
	const effect = c.event.effect.kind === "stays" ? "" : `  ${formatEffect(c.event.effect)}`;
	const flags = c.findings.length ? `  !${c.findings.length}` : "";
	return `#${c.id.padEnd(3)} ${c.event.interaction.padEnd(6)} ${element(c).padEnd(36)} ${props}${effect}${flags}`;
}

function element(c: EventCard): string {
	return [c.event.component ?? "screen", c.event.element].filter(Boolean).join(".");
}

function line(f: Finding): string {
	return `! ${f.severity.padEnd(5)} ${f.code}${f.seq !== null ? ` #${f.seq}` : ""}: ${f.detail}`;
}
