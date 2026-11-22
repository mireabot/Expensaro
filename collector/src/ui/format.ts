import { formatEffect, screenKey, type PropValue } from "../model";
import type { EventCard, Severity } from "../narrative";

export function clock(d: Date): string {
	return d.toLocaleTimeString([], { hour12: false, hour: "2-digit", minute: "2-digit", second: "2-digit" }) + "." + String(d.getMilliseconds()).padStart(3, "0");
}

export function delta(ms: number | null): string {
	if (ms === null) return "";
	if (ms < 1000) return `+${ms}ms`;
	if (ms < 60_000) return `+${(ms / 1000).toFixed(1)}s`;
	return `+${Math.floor(ms / 60_000)}m${Math.round((ms % 60_000) / 1000)}s`;
}

export function duration(ms: number | null): string {
	if (ms === null) return "—";
	const s = Math.round(ms / 1000);
	return s < 60 ? `${s}s` : `${Math.floor(s / 60)}m ${s % 60}s`;
}

export function elementLabel(card: EventCard): string {
	const { component, element } = card.event;
	if (component === null) return "screen";
	return element === null ? component : `${component}.${element}`;
}

export function describe(card: EventCard): string {
	const e = card.event;
	const what = e.effect.kind === "stays" ? "stays" : formatEffect(e.effect).replace("(", " → ").replace(")", "");
	return `${e.interaction} · ${what}${e.domain !== "none" ? ` · ${e.domain}` : ""}`;
}

export function value(v: PropValue | null | undefined): string {
	if (v === null || v === undefined) return "—";
	if (typeof v === "string") return v === "" ? '""' : v;
	return String(v);
}

export const severityTone: Record<Severity, string> = {
	error: "bg-rose-500",
	warn: "bg-amber-500",
	info: "bg-sky-400",
};

export function worst(findings: { severity: Severity }[]): Severity | null {
	if (findings.some((f) => f.severity === "error")) return "error";
	if (findings.some((f) => f.severity === "warn")) return "warn";
	if (findings.some((f) => f.severity === "info")) return "info";
	return null;
}

export { screenKey };
