/**
 * Domain types shared by wire parsing, the store, the narrative and fixtures.
 * Two families: records (what the app said, parsed and faithful) and the narrative
 * (what it means, derived by narrate() and never stored).
 */

export type SessionId = string & { readonly __brand: "SessionId" };
export type Seq = number & { readonly __brand: "Seq" };
/** `${seq}` normally; `${seq}~${line}` for the second body of a conflicting seq. */
export type CardId = string & { readonly __brand: "CardId" };

/** One JSONL line in sessions/<id>.jsonl. Written once, never rewritten. */
export interface StoredRecord {
	line: number;
	receivedAt: string;
	source: string;
	body: unknown;
}

export const RECORD_KINDS = ["session_init", "session_update", "event"] as const;
export const OWNERS = ["screen", "shell"] as const;
export const INTERACTIONS = ["view", "tap", "submit"] as const;
export const SESSION_FIELDS = ["currency", "notifications_enabled", "launch_root"] as const;
/**
 * Spec §7.3. Until the spec package exists (phase 2) this is the one copy; phase 2 derives it
 * from presents(...) edges and deletes this list.
 */
export const HOSTS = [
	"transaction_form",
	"payment_form",
	"daily_transaction_form",
	"goal_form",
	"category_picker",
	"category_form",
	"permissions",
	"daily_transactions",
] as const;

export type Owner = (typeof OWNERS)[number];
export type Interaction = (typeof INTERACTIONS)[number];
export type SessionField = (typeof SESSION_FIELDS)[number];

export const SESSION_INIT_FIELDS = [
	"spec_version",
	"app_version",
	"build",
	"platform",
	"os_version",
	"device_class",
	"locale",
	"time_zone",
	"currency",
	"schema_version",
	"launch_root",
	"notifications_enabled",
	"reduce_motion",
] as const;

export interface SessionFields {
	spec_version: string;
	app_version: string;
	build: string;
	platform: "ios";
	os_version: string;
	device_class: "phone" | "pad";
	locale: string;
	time_zone: string;
	currency: string;
	schema_version: string;
	launch_root: "onboarding" | "home";
	notifications_enabled: boolean;
	reduce_motion: boolean;
}

export type ScreenRef = { layer: string; screen: string };

export type Effect =
	| { kind: "stays" }
	| { kind: "reroots" }
	| { kind: "navigates"; to: ScreenRef | "previous" }
	| { kind: "presents"; presentation: string; mode: string | null };

export type PropValue = string | number | boolean;

export interface TrackedEvent {
	seq: Seq;
	at: Date;
	owner: Owner;
	layer: string;
	screen: string;
	/** null on a screen's own view. */
	component: string | null;
	/** null on a screen or presentation view. */
	element: string | null;
	interaction: Interaction;
	effect: Effect;
	domain: string;
	props: Readonly<Record<string, PropValue>>;
	host: string | null;
}

export type DomainRecord =
	| { kind: "session_init"; sessionId: SessionId; startedAt: Date; fields: SessionFields }
	| { kind: "session_update"; sessionId: SessionId; seq: Seq; at: Date; field: SessionField; value: PropValue }
	| { kind: "event"; sessionId: SessionId; event: TrackedEvent };

export function screenKey(ref: ScreenRef): string {
	return `${ref.layer}.${ref.screen}`;
}

export function formatEffect(effect: Effect): string {
	switch (effect.kind) {
		case "stays":
		case "reroots":
			return effect.kind;
		case "navigates":
			return `navigates(${effect.to === "previous" ? "previous" : screenKey(effect.to)})`;
		case "presents":
			return effect.mode ? `presents(${effect.presentation}, ${effect.mode})` : `presents(${effect.presentation})`;
	}
}
