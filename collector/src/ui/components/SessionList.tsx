/** Left rail. One row per session: start time + live dot, app and device, launch root / source chips. */

import { Trash2 } from "lucide-react";
import type { SessionListItem } from "../../store";
import { cn } from "../lib/utils";

export function SessionList(props: {
	sessions: SessionListItem[];
	selected: string | null;
	onSelect(id: string): void;
	onDelete(id: string): void;
}) {
	return (
		<aside className="flex h-full w-72 shrink-0 flex-col border-r bg-white">
			<div className="flex items-center justify-between border-b px-4 py-3">
				<div>
					<div className="text-sm font-semibold">Sessions</div>
					<div className="text-xs text-muted-foreground">Expensaro collector</div>
				</div>
				<span className="rounded-full bg-secondary px-2 py-0.5 text-xs font-medium text-muted-foreground">{props.sessions.length}</span>
			</div>
			<div className="flex-1 overflow-y-auto">
				{props.sessions.length === 0 && (
					<div className="p-4 text-xs leading-relaxed text-muted-foreground">
						No sessions yet. Run <code className="rounded bg-secondary px-1 font-mono">reflex replay home-day --pace live</code> or point the app at
						<code className="ml-1 rounded bg-secondary px-1 font-mono">POST /v1/records</code>.
					</div>
				)}
				{props.sessions.map((s) => {
					const started = s.startedAt ? new Date(s.startedAt) : new Date(s.lastReceivedAt);
					return (
						<button
							key={s.id}
							onClick={() => props.onSelect(s.id)}
							className={cn(
								"group relative block w-full border-b px-4 py-3 text-left transition-colors hover:bg-secondary/60",
								props.selected === s.id && "bg-secondary",
							)}
						>
							{props.selected === s.id && <span className="absolute inset-y-0 left-0 w-0.5 bg-violet-500" />}
							<div className="flex items-center gap-2">
								<span className="font-mono text-sm font-medium tabular-nums">
									{started.toLocaleTimeString([], { hour12: false })}
								</span>
								<span className="text-xs text-muted-foreground">{started.toLocaleDateString([], { month: "short", day: "numeric" })}</span>
								{s.live && <span className="h-2 w-2 animate-pulse rounded-full bg-emerald-500" title="receiving" />}
								<span
									role="button"
									onClick={(e) => {
										e.stopPropagation();
										props.onDelete(s.id);
									}}
									className="ml-auto rounded p-1 text-muted-foreground opacity-0 hover:bg-white hover:text-rose-600 group-hover:opacity-100"
									title="Delete session"
								>
									<Trash2 className="h-3.5 w-3.5" />
								</span>
							</div>
							<div className="mt-0.5 truncate text-xs text-muted-foreground">
								{s.appLabel ?? "no session_init"} {s.device ? `· ${s.device}` : ""}
							</div>
							<div className="mt-1.5 flex flex-wrap gap-1">
								{s.launchRoot && <Chip>{s.launchRoot}</Chip>}
								<Chip tone={s.source.startsWith("fixture") ? "violet" : "slate"}>{s.source}</Chip>
								<Chip>{s.records} rec</Chip>
							</div>
						</button>
					);
				})}
			</div>
		</aside>
	);
}

function Chip(props: { children: React.ReactNode; tone?: "violet" | "slate" }) {
	return (
		<span
			className={cn(
				"rounded px-1.5 py-0.5 font-mono text-[10px]",
				props.tone === "violet" ? "bg-violet-100 text-violet-700" : "bg-secondary text-muted-foreground",
			)}
		>
			{props.children}
		</span>
	);
}
