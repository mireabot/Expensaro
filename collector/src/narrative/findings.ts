/**
 * Everything the collector can say is wrong without the spec table: envelope integrity, narrative
 * consistency, and the §7.1/§7.4 conventions that need no row lookup. Row-level conformance arrives
 * with the spec package (phase 2) as a separate pure pass.
 */

import { SESSION_INIT_FIELDS, type CardId, type PropValue, type Seq, type TrackedEvent } from "../model";

export const FINDINGS = {
	malformed: { severity: "error", title: "Record could not be parsed", ref: "§1b" },
	missing_init: { severity: "error", title: "No session_init", ref: "§1b" },
	duplicate_init: { severity: "error", title: "More than one session_init", ref: "§1b" },
	init_not_first: { severity: "warn", title: "session_init arrived after events", ref: "§1b" },
	seq_gap: { severity: "warn", title: "Missing seq numbers", ref: "§1b" },
	seq_conflict: { severity: "error", title: "Same seq, different body", ref: "§1b" },
	seq_retry: { severity: "info", title: "Same seq, identical body (retry collapsed)", ref: "§1b" },
	late_arrival: { severity: "info", title: "Arrived out of seq order", ref: "§1b" },
	unknown_field: { severity: "warn", title: "Unexpected top-level field", ref: "§1b" },
	unfulfilled_navigation: { severity: "error", title: "navigates(x) but x never appeared", ref: "§7.2" },
	unexplained_arrival: { severity: "warn", title: "Screen changed without navigates or tab", ref: "§7.2" },
	host_mismatch: { severity: "error", title: "host differs from the open presentation", ref: "§7.3" },
	missing_host: { severity: "warn", title: "Nested presentation event without host", ref: "§7.3" },
	implicit_presentation: { severity: "info", title: "Presentation opened without a presents event", ref: "§7.2" },
	empty_presentation: { severity: "warn", title: "presents(x) but x logged nothing", ref: "§7.2" },
	shell_screen_mismatch: { severity: "warn", title: "Shell event reports a different screen", ref: "§1" },
	noop_update: { severity: "info", title: "session_update to the current value", ref: "§1b" },
	non_snake_id: { severity: "warn", title: "Id is not snake_case", ref: "§7.1" },
	free_text_suspect: { severity: "error", title: "String prop looks like free text", ref: "§7.4" },
	session_field_on_event: { severity: "error", title: "Session constant sent as an event prop", ref: "§7.4" },
} as const satisfies Record<string, { severity: Severity; title: string; ref: string }>;

export type Severity = "error" | "warn" | "info";
export type FindingCode = keyof typeof FINDINGS;

export interface Finding {
	code: FindingCode;
	severity: Severity;
	card: CardId | null;
	seq: Seq | null;
	detail: string;
}

export function finding(code: FindingCode, at: { card: CardId | null; seq: Seq | null }, detail: string): Finding {
	return { code, severity: FINDINGS[code].severity, card: at.card, seq: at.seq, detail };
}

const SNAKE = /^[a-z][a-z0-9_]*$/;
const ENUMISH = /^[a-z0-9][a-z0-9_]*$/;
const SESSION_KEYS = new Set<string>(SESSION_INIT_FIELDS);

/** Every string prop is an enum value (§7.4), so anything not snake_case-ish is suspect. */
export function looksLikeFreeText(value: PropValue): boolean {
	return typeof value === "string" && !ENUMISH.test(value);
}

export function checkEvent(e: TrackedEvent): Array<[FindingCode, string]> {
	const out: Array<[FindingCode, string]> = [];
	const ids = { layer: e.layer, screen: e.screen, component: e.component, element: e.element, domain: e.domain, host: e.host };
	for (const [name, value] of Object.entries(ids)) {
		if (value !== null && !SNAKE.test(value)) out.push(["non_snake_id", `${name} "${value}"`]);
	}
	for (const [key, value] of Object.entries(e.props)) {
		if (SESSION_KEYS.has(key)) out.push(["session_field_on_event", `prop ${key} belongs in session_init`]);
		else if (looksLikeFreeText(value)) out.push(["free_text_suspect", `${key} = ${JSON.stringify(value)}`]);
	}
	return out;
}
