/**
 * Session list on the left; the selected session's header and stream in the middle; the detail
 * slider over the right edge. Keyboard: j/k walk cards, Esc closes the slider.
 */

import { Eye, EyeOff } from "lucide-react";
import { useEffect, useState } from "react";
import { DetailSheet } from "./components/DetailSheet";
import { SessionHeader } from "./components/SessionHeader";
import { SessionList } from "./components/SessionList";
import { Stream } from "./components/Stream";
import { deleteSession, useRoute, useSession, useSessionList } from "./data";

export function App() {
	const sessions = useSessionList();
	const [route, navigate] = useRoute();
	const session = useSession(route.sessionId);
	const [hideViews, setHideViews] = useState(false);

	useEffect(() => {
		if (!route.sessionId && sessions[0]) navigate({ sessionId: sessions[0].id, cardId: null });
	}, [route.sessionId, sessions]);

	useEffect(() => {
		const onKey = (e: KeyboardEvent) => {
			if (!session || (e.target as HTMLElement).tagName === "INPUT") return;
			if (e.key === "Escape") navigate({ sessionId: route.sessionId, cardId: null });
			if (e.key !== "j" && e.key !== "k") return;
			const i = session.cards.findIndex((c) => c.id === route.cardId);
			const next = session.cards[e.key === "j" ? i + 1 : Math.max(i - 1, 0)];
			if (next) navigate({ sessionId: route.sessionId, cardId: next.id });
		};
		addEventListener("keydown", onKey);
		return () => removeEventListener("keydown", onKey);
	}, [session, route]);

	useEffect(() => {
		if (route.cardId) document.getElementById(`card-${route.cardId}`)?.scrollIntoView({ block: "nearest", behavior: "smooth" });
	}, [route.cardId]);

	const openSeq = (seq: number) => {
		const card = session?.cards.find((c) => c.event.seq >= seq);
		if (card) navigate({ sessionId: route.sessionId, cardId: card.id });
	};

	return (
		<div className="flex h-screen overflow-hidden">
			<SessionList
				sessions={sessions}
				selected={route.sessionId}
				onSelect={(id) => navigate({ sessionId: id, cardId: null })}
				onDelete={async (id) => {
					await deleteSession(id);
					if (route.sessionId === id) navigate({ sessionId: null, cardId: null });
				}}
			/>
			<main className={`flex-1 overflow-y-auto ${route.cardId ? "pr-[460px]" : ""}`}>
				{session ? (
					<>
						<SessionHeader session={session} onJump={openSeq} />
						<div className="flex items-center justify-between border-b bg-white px-8 py-2">
							<span className="text-xs text-muted-foreground">
								{session.stats.visits} screen visits · j/k to step through events
							</span>
							<button
								onClick={() => setHideViews(!hideViews)}
								className="flex items-center gap-1.5 rounded-md border px-2.5 py-1 text-xs text-muted-foreground hover:bg-secondary hover:text-foreground"
							>
								{hideViews ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
								{hideViews ? "Views hidden" : "Hide views"}
							</button>
						</div>
						<Stream visits={session.visits} selected={route.cardId} onSelect={(id) => navigate({ sessionId: route.sessionId, cardId: id })} hideViews={hideViews} />
					</>
				) : (
					<div className="flex h-full items-center justify-center text-sm text-muted-foreground">Select a session</div>
				)}
			</main>
			{session && route.cardId && (
				<DetailSheet
					session={session}
					cardId={route.cardId}
					onNavigate={(id) => navigate({ sessionId: route.sessionId, cardId: id })}
					onClose={() => navigate({ sessionId: route.sessionId, cardId: null })}
				/>
			)}
		</div>
	);
}
