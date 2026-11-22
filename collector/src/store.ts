/**
 * The recorder. Sole owner of <dataDir>/sessions/<session_id>.jsonl.
 *
 * Invariants: a line is never rewritten, and the line index is the read cursor, so read(id, after)
 * is idempotent. Nothing is interpreted here. Appends to one session are serialized through a
 * promise chain so file order, mirror order and cursor order agree. A torn final line after a crash
 * is kept as a raw string body, which narrate() reports as malformed.
 */

import { mkdir, readdir, rm, appendFile } from "node:fs/promises";
import { join } from "node:path";
import type { StoredRecord } from "./model";
import { parseRecord, routeKey } from "./wire";

export interface SessionSummary {
	id: string;
	records: number;
	firstReceivedAt: string;
	lastReceivedAt: string;
	source: string;
	head: StoredRecord | null;
}

export interface SessionListItem {
	id: string;
	source: string;
	startedAt: string | null;
	appLabel: string | null;
	device: string | null;
	launchRoot: string | null;
	records: number;
	lastReceivedAt: string;
	live: boolean;
}

export interface SessionStore {
	append(batch: readonly unknown[], source: string): Promise<{ accepted: number; sessions: string[] }>;
	list(): SessionSummary[];
	read(id: string, after: number): Promise<{ records: StoredRecord[]; next: number } | null>;
	remove(id: string): Promise<boolean>;
}

export async function openStore(dataDir: string): Promise<SessionStore> {
	const dir = join(dataDir, "sessions");
	await mkdir(dir, { recursive: true });

	const index = new Map<string, SessionSummary>();
	const mirror = new Map<string, StoredRecord[]>();
	const queues = new Map<string, Promise<void>>();

	for (const name of await readdir(dir)) {
		if (!name.endsWith(".jsonl")) continue;
		const id = name.slice(0, -".jsonl".length);
		const records = await load(join(dir, name));
		if (!records.length) continue;
		mirror.set(id, records);
		index.set(id, summarize(id, records));
	}

	return {
		async append(batch, source) {
			const receivedAt = new Date().toISOString();
			const groups = new Map<string, unknown[]>();
			for (const body of batch) {
				const id = routeKey(body);
				groups.set(id, [...(groups.get(id) ?? []), body]);
			}
			await Promise.all(
				[...groups].map(([id, bodies]) => {
					const previous = queues.get(id) ?? Promise.resolve();
					const next = previous.then(async () => {
						const records = mirror.get(id) ?? [];
						const added = bodies.map((body, i) => ({ line: records.length + i, receivedAt, source, body }));
						await appendFile(join(dir, `${id}.jsonl`), added.map((r) => JSON.stringify(r) + "\n").join(""));
						records.push(...added);
						mirror.set(id, records);
						index.set(id, summarize(id, records));
					});
					queues.set(id, next.catch(() => {}));
					return next;
				}),
			);
			return { accepted: batch.length, sessions: [...groups.keys()] };
		},
		list() {
			return [...index.values()].sort((a, b) => b.lastReceivedAt.localeCompare(a.lastReceivedAt));
		},
		async read(id, after) {
			await queues.get(id);
			const records = mirror.get(id);
			if (!records) return null;
			return { records: records.slice(after), next: records.length };
		},
		async remove(id) {
			if (!index.has(id)) return false;
			await queues.get(id);
			await rm(join(dir, `${id}.jsonl`), { force: true });
			index.delete(id);
			mirror.delete(id);
			queues.delete(id);
			return true;
		},
	};
}

/** Reads a stored session file (also used by `reflex print` and replay). */
export async function load(path: string): Promise<StoredRecord[]> {
	const text = await Bun.file(path).text();
	return text
		.split("\n")
		.filter((l) => l.trim() !== "")
		.map((l, line) => {
			try {
				const parsed = JSON.parse(l) as StoredRecord;
				return { ...parsed, line };
			} catch {
				return { line, receivedAt: new Date(0).toISOString(), source: "unknown", body: l };
			}
		});
}

export function listItem(summary: SessionSummary, now: Date): SessionListItem {
	const parsed = summary.head ? parseRecord(summary.head) : null;
	const init = parsed?.ok && parsed.record.kind === "session_init" ? parsed.record : null;
	return {
		id: summary.id,
		source: summary.source,
		startedAt: init ? init.startedAt.toISOString() : null,
		appLabel: init ? `${init.fields.app_version} (${init.fields.build})` : null,
		device: init ? `iOS ${init.fields.os_version} · ${init.fields.device_class}` : null,
		launchRoot: init ? init.fields.launch_root : null,
		records: summary.records,
		lastReceivedAt: summary.lastReceivedAt,
		live: now.getTime() - new Date(summary.lastReceivedAt).getTime() < 30_000,
	};
}

function summarize(id: string, records: StoredRecord[]): SessionSummary {
	const first = records[0]!;
	const last = records[records.length - 1]!;
	const head = records.find((r) => (r.body as { kind?: unknown } | null)?.kind === "session_init") ?? first;
	return {
		id,
		records: records.length,
		firstReceivedAt: first.receivedAt,
		lastReceivedAt: last.receivedAt,
		source: first.source,
		head,
	};
}
