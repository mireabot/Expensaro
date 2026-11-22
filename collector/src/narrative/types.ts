import type { CardId, PropValue, ScreenRef, Seq, SessionField, SessionFields, SessionId, TrackedEvent } from "../model";
import type { Finding, Severity } from "./findings";

export interface Session {
	id: SessionId;
	source: string;
	context: SessionContext;
	/** One entry per screen stay, in order. A revisit is a new visit. */
	visits: Visit[];
	/** Flat, seq-ordered; the same objects referenced from visits. */
	cards: EventCard[];
	malformed: MalformedRecord[];
	findings: Finding[];
	stats: SessionStats;
}

export interface SessionContext {
	init: { startedAt: Date; fields: SessionFields } | null;
	changes: FieldChange[];
	current: SessionFields | null;
}

export interface FieldChange {
	seq: Seq;
	at: Date;
	field: SessionField;
	from: PropValue | null;
	to: PropValue;
}

export interface Visit {
	index: number;
	screen: ScreenRef;
	arrival: Arrival;
	startedAt: Date;
	items: StreamItem[];
}

export type Arrival =
	| { kind: "launch" }
	| { kind: "navigated"; via: CardId; fromVisit: number }
	| { kind: "popped"; via: CardId; fromVisit: number }
	| { kind: "tab"; via: CardId }
	| { kind: "unexplained" };

export type StreamItem =
	| { kind: "card"; card: EventCard; reply: Reply | null }
	| { kind: "views"; cards: EventCard[] }
	| { kind: "context"; change: FieldChange }
	/** A presentation whose events arrived without a presents event (inferred from host). */
	| { kind: "implicit"; presentation: Presentation };

export type Reply =
	| { kind: "thread"; presentation: Presentation }
	| { kind: "jump"; target: ScreenRef | "previous"; toVisit: number | null; fulfilled: boolean }
	| { kind: "reroot" };

export interface Presentation {
	name: string;
	mode: string | null;
	openedBy: CardId | null;
	depth: number;
	items: StreamItem[];
}

export interface EventCard {
	id: CardId;
	event: TrackedEvent;
	path: string;
	visit: number;
	chain: string[];
	sincePrevMs: number | null;
	sinceStartMs: number | null;
	findings: Finding[];
	receivedAt: string;
	line: number;
	raw: unknown;
}

export interface MalformedRecord {
	line: number;
	receivedAt: string;
	reason: string;
	raw: unknown;
}

export interface SessionStats {
	durationMs: number | null;
	events: number;
	visits: number;
	screens: number;
	presentations: number;
	findings: Record<Severity, number>;
}
