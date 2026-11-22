/**
 * How sessions exist before the Swift layer does. A scenario is a script that emits WireRecord[],
 * written while reading the spec (each step cites its §9 row). The builder is shaped like the
 * planned Swift API: `on(screen)` ~ a screen root, `within(presentation)` ~ the scope that fills
 * component and host, step methods ~ `track.<element>.<verb>()`. It shares no code with narrate(),
 * so a passing fixture means two independent producers agree.
 *
 * Like the Swift runtime will, the builder emits implied views: a screen view when a screen
 * becomes visible after navigates/tab/launch, and a presentation view on every presents.
 */

import { HOSTS, type PropValue, type SessionField } from "../model";
import type { WireEffect, WireRecord, WireSessionInit } from "../wire";

export interface ExpectedFinding {
	seq: number | null;
	code: string;
}

export interface Fixture {
	name: string;
	summary: string;
	/** Findings narrate() must produce, exactly (order-insensitive). [] for well-formed scenarios. */
	expect: ExpectedFinding[];
	records: unknown[];
}

type Props = Record<string, PropValue>;

export interface Step {
	effect?: WireEffect;
	domain: string;
	props?: Props;
	afterMs?: number;
}

export interface Scope {
	view(element: string, step: Step): void;
	tap(element: string, step: Step): void;
	submit(element: string, step: Step): void;
	within(presentation: string, body: (s: Scope) => void): void;
}

export interface Script {
	/** Sets the screen the next events happen on. Emits its view only when a navigation or launch made it visible. */
	on(screen: `${string}.${string}`): void;
	at(component: string): Scope;
	within(presentation: string, body: (s: Scope) => void): void;
	shell(component: "tab_bar" | "accessory"): Scope;
	update(field: SessionField, value: string | boolean): void;
	wait(ms: number): void;
	/** Any JSON, sent verbatim. Does not consume a seq. */
	raw(body: unknown): void;
	/** Rewinds the seq counter, for retry and conflict fixtures. */
	reuseSeq(seq: number): void;
}

const T0 = Date.parse("2026-11-22T09:00:00.000Z");
const HOST_SET = new Set<string>(HOSTS);

export function scenario(
	meta: Omit<Fixture, "records">,
	init: Partial<Omit<WireSessionInit, "kind" | "session_id" | "started_at">> | null,
	script: (s: Script) => void,
): Fixture {
	const sessionId = `fixture-${meta.name}`;
	const records: unknown[] = [];
	let seq = 0;
	let clock = T0;
	let screen: { layer: string; screen: string } | null = null;
	let visible: string | null = null;
	let pendingView = true;
	const modes = new Map<string, string | null>();

	const stamp = (afterMs = 400) => {
		clock += afterMs;
		return new Date(clock).toISOString();
	};

	if (init !== null) {
		records.push({
			kind: "session_init",
			session_id: sessionId,
			started_at: new Date(clock).toISOString(),
			spec_version: "3.0",
			app_version: "3.4.0",
			build: "412",
			platform: "ios",
			os_version: "18.2",
			device_class: "phone",
			locale: "en_US",
			time_zone: "Europe/Berlin",
			currency: "USD",
			schema_version: "1.0.0",
			launch_root: "home",
			notifications_enabled: true,
			reduce_motion: false,
			...init,
		} satisfies WireSessionInit);
	}

	const emit = (
		owner: "screen" | "shell",
		component: string | null,
		element: string | null,
		interaction: "view" | "tap" | "submit",
		step: Step,
		host: string | null,
	) => {
		if (!screen) throw new Error(`${meta.name}: call on(screen) before emitting events`);
		const record: WireRecord = {
			kind: "event",
			session_id: sessionId,
			seq: ++seq,
			timestamp: stamp(step.afterMs),
			owner,
			layer: screen.layer,
			screen: screen.screen,
			component,
			element,
			interaction,
			effect: step.effect ?? "stays",
			domain: step.domain,
			props: { ...(step.props ?? {}) },
			...(host ? { host } : {}),
		};
		records.push(record);
		if (record.effect.startsWith("navigates(")) pendingView = true;
	};

	const ensureVisible = () => {
		if (!screen) return;
		const key = `${screen.layer}.${screen.screen}`;
		if (pendingView || visible !== key) {
			pendingView = false;
			visible = key;
			emit("screen", null, null, "view", { domain: "none", afterMs: 300 }, null);
		}
	};

	const scope = (owner: "screen" | "shell", component: string, chain: string[]): Scope => {
		const host = () => {
			const parent = chain[chain.length - 2];
			return parent && HOST_SET.has(parent) ? parent : null;
		};
		const step = (interaction: "view" | "tap" | "submit") => (element: string, s: Step) => {
			if (owner === "screen") ensureVisible();
			const props = { ...(s.props ?? {}) };
			const mode = modes.get(component);
			if (mode && !("mode" in props) && owner === "screen") props.mode = mode;
			emit(owner, component, element, interaction, { ...s, props }, owner === "screen" ? host() : null);
			const presented = /^presents\(([a-z0-9_]+)(?:,\s*([a-z0-9_]+))?\)$/.exec(s.effect ?? "");
			if (presented) {
				const name = presented[1]!;
				modes.set(name, presented[2] ?? null);
				const nextChain = owner === "shell" ? [name] : [...chain, name];
				const parent = nextChain[nextChain.length - 2];
				emit("screen", name, null, "view", { domain: s.domain, afterMs: 250 }, parent && HOST_SET.has(parent) ? parent : null);
			}
		};
		return {
			view: step("view"),
			tap: step("tap"),
			submit: step("submit"),
			within: (presentation, body) => body(scope("screen", presentation, [...chain, presentation])),
		};
	};

	script({
		on(next) {
			const [layer, name] = next.split(".") as [string, string];
			screen = { layer, screen: name };
		},
		at: (component) => scope("screen", component, []),
		within: (presentation, body) => body(scope("screen", presentation, [presentation])),
		shell: (component) => {
			const s = scope("shell", component, []);
			return {
				...s,
				tap(element, step) {
					ensureVisible();
					s.tap(element, step);
					if (component === "tab_bar") pendingView = true;
				},
			};
		},
		update(field, value) {
			records.push({ kind: "session_update", session_id: sessionId, seq: ++seq, timestamp: stamp(50), field, value });
		},
		wait(ms) {
			clock += ms;
		},
		raw(body) {
			records.push(body);
		},
		reuseSeq(n) {
			seq = n - 1;
		},
	});

	return { ...meta, records };
}
