/**
 * Sends a fixture or a recorded session through the real ingest path (HTTP POST), as the Swift sink
 * will. Rebase (default) gives each replay a fresh session id and shifts timestamps to now, so two
 * replays are two sessions rather than one full of retries.
 */

import { fixtureByName } from "./fixtures";
import { load } from "./store";

export interface ReplayOptions {
	to: string;
	pace: "instant" | "live" | number;
	rebase: boolean;
}

export async function loadRecords(target: string): Promise<{ name: string; records: unknown[] }> {
	const fixture = fixtureByName(target);
	if (fixture) return { name: fixture.name, records: fixture.records };
	const stored = await load(target);
	return { name: target.split("/").pop()!.replace(/\.jsonl$/, ""), records: stored.map((r) => r.body) };
}

export function rebase(records: readonly unknown[], name: string, now: Date): unknown[] {
	const sessionId = `${name}-${crypto.randomUUID().slice(0, 8)}`;
	const first = records
		.map((r) => (r as Record<string, unknown>)?.started_at ?? (r as Record<string, unknown>)?.timestamp)
		.find((t): t is string => typeof t === "string");
	const shift = first ? now.getTime() - Date.parse(first) : 0;
	const move = (t: unknown) => (typeof t === "string" && !Number.isNaN(Date.parse(t)) ? new Date(Date.parse(t) + shift).toISOString() : t);
	return records.map((r) => {
		if (typeof r !== "object" || r === null || Array.isArray(r)) return r;
		const o = { ...(r as Record<string, unknown>) };
		if ("session_id" in o) o.session_id = sessionId;
		if ("started_at" in o) o.started_at = move(o.started_at);
		if ("timestamp" in o) o.timestamp = move(o.timestamp);
		return o;
	});
}

export async function replay(name: string, records: readonly unknown[], opts: ReplayOptions): Promise<{ sessionId: string; sent: number }> {
	const batch = opts.rebase ? rebase(records, name, new Date()) : [...records];
	const sessionId = String((batch.find((r) => (r as { session_id?: unknown })?.session_id) as { session_id?: string })?.session_id ?? name);
	const post = (body: unknown[]) =>
		fetch(new URL("/v1/records", opts.to), {
			method: "POST",
			headers: { "Content-Type": "application/json", "x-reflex-source": `fixture:${name}` },
			body: JSON.stringify(body),
		}).then((r) => {
			if (!r.ok) throw new Error(`collector answered ${r.status}`);
		});

	if (opts.pace === "instant") {
		await post(batch);
		return { sessionId, sent: batch.length };
	}
	let previous: number | null = null;
	for (const record of batch) {
		const t = Date.parse(String((record as Record<string, unknown>)?.timestamp ?? (record as Record<string, unknown>)?.started_at ?? ""));
		const gap = opts.pace === "live" ? (previous !== null && !Number.isNaN(t) ? Math.min(Math.max(t - previous, 0), 4000) : 0) : opts.pace;
		if (gap > 0) await Bun.sleep(gap);
		if (!Number.isNaN(t)) previous = t;
		await post([record]);
	}
	return { sessionId, sent: batch.length };
}
