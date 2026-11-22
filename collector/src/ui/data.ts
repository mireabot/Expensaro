/**
 * The UI's only I/O: polling with a line cursor (only new lines come back), narrate() on growth,
 * and a hash route (#/s/<session>/e/<card>) so "Copy URL" reopens the same card.
 */

import { useEffect, useMemo, useRef, useState } from "react";
import type { StoredRecord } from "../model";
import { narrate, type Session } from "../narrative";
import type { SessionListItem } from "../store";

export function useSessionList(): SessionListItem[] {
	const [sessions, setSessions] = useState<SessionListItem[]>([]);
	useEffect(() => {
		let alive = true;
		const tick = async () => {
			const res = await fetch("/v1/sessions").catch(() => null);
			if (alive && res?.ok) setSessions(await res.json());
		};
		tick();
		const timer = setInterval(tick, 2000);
		return () => {
			alive = false;
			clearInterval(timer);
		};
	}, []);
	return sessions;
}

export function useSession(id: string | null): Session | null {
	const records = useRef<StoredRecord[]>([]);
	const [count, setCount] = useState(0);

	useEffect(() => {
		records.current = [];
		setCount(0);
		if (!id) return;
		let alive = true;
		let next = 0;
		const tick = async () => {
			const res = await fetch(`/v1/sessions/${id}/records?after=${next}`).catch(() => null);
			if (!alive || !res?.ok) return;
			const page = (await res.json()) as { records: StoredRecord[]; next: number };
			next = page.next;
			if (page.records.length) {
				records.current = [...records.current, ...page.records];
				setCount(records.current.length);
			}
		};
		tick();
		const timer = setInterval(tick, 1000);
		return () => {
			alive = false;
			clearInterval(timer);
		};
	}, [id]);

	return useMemo(() => (id && count ? narrate(records.current, id) : null), [id, count]);
}

export interface Route {
	sessionId: string | null;
	cardId: string | null;
}

function parseHash(): Route {
	const m = /^#\/s\/([^/]+)(?:\/e\/(.+))?$/.exec(location.hash);
	return { sessionId: m?.[1] ? decodeURIComponent(m[1]) : null, cardId: m?.[2] ? decodeURIComponent(m[2]) : null };
}

export function useRoute(): [Route, (next: Route) => void] {
	const [route, setRoute] = useState(parseHash);
	useEffect(() => {
		const onHash = () => setRoute(parseHash());
		addEventListener("hashchange", onHash);
		return () => removeEventListener("hashchange", onHash);
	}, []);
	const navigate = (next: Route) => {
		location.hash = next.sessionId ? `/s/${encodeURIComponent(next.sessionId)}${next.cardId ? `/e/${encodeURIComponent(next.cardId)}` : ""}` : "";
	};
	return [route, navigate];
}

export async function deleteSession(id: string): Promise<void> {
	await fetch(`/v1/sessions/${id}`, { method: "DELETE" });
}
