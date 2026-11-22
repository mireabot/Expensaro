/**
 * Bun.serve, thin: every route is one call into the store. Interpretation happens in the browser
 * (and in `reflex print`) through narrate().
 *
 *   POST   /v1/records                       WireRecord[]   (x-reflex-source: "fixture:<name>")
 *   GET    /v1/sessions                      SessionListItem[]
 *   GET    /v1/sessions/:id/records?after=n  { records, next }
 *   DELETE /v1/sessions/:id
 *   GET    /*                                the UI
 */

import index from "./ui/index.html";
import { listItem, type SessionStore } from "./store";

const CORS = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS", "Access-Control-Allow-Headers": "*" };

const json = (body: unknown, status = 200) =>
	new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json", ...CORS } });

export function serve(opts: { port: number; store: SessionStore }) {
	const { store } = opts;
	return Bun.serve({
		port: opts.port,
		development: process.env.REFLEX_DEV === "1",
		routes: {
			"/": index,
			"/v1/records": {
				OPTIONS: () => new Response(null, { headers: CORS }),
				POST: async (req) => {
					const body = await req.json().catch(() => undefined);
					if (!Array.isArray(body)) return json({ error: "expected a JSON array of records" }, 400);
					logLines(body);
					return json(await store.append(body, req.headers.get("x-reflex-source") ?? "device"));
				},
			},
			"/v1/sessions": { GET: () => json(store.list().map((s) => listItem(s, new Date()))) },
			"/v1/sessions/:id/records": {
				GET: async (req) => {
					const after = Number(new URL(req.url).searchParams.get("after") ?? 0) || 0;
					const page = await store.read(req.params.id, after);
					return page ? json(page) : json({ error: "unknown session" }, 404);
				},
			},
			"/v1/sessions/:id": {
				DELETE: async (req) => ((await store.remove(req.params.id)) ? new Response(null, { status: 204, headers: CORS }) : json({ error: "unknown session" }, 404)),
			},
		},
		fetch: () => new Response("Not found", { status: 404 }),
	});
}

function logLines(batch: unknown[]) {
	for (const r of batch as Array<Record<string, unknown>>) {
		const id = String(r?.session_id ?? "?").slice(0, 8);
		if (r?.kind === "event") {
			const path = [r.layer, r.screen, r.component, r.element].filter(Boolean).join(".");
			console.log(`[REC] ${id} #${r.seq} ${r.interaction} ${path} -> ${r.effect}`);
		} else {
			console.log(`[REC] ${id} ${r?.kind ?? "unknown"}${r?.kind === "session_update" ? ` ${r.field}=${JSON.stringify(r.value)}` : ""}`);
		}
	}
}
