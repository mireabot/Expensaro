/**
 * One event as a chat message. Amplitude stream row (time gutter + event name) with logging-proxy's
 * card vocabulary: colored interaction pill, mono key/value chips, status edge by severity.
 * Screen-owned cards sit left; shell-owned cards sit right like the other chat speaker.
 */

import { ArrowRight, CornerDownRight, RotateCw } from "lucide-react";
import { screenKey } from "../../model";
import type { EventCard as Card, Reply } from "../../narrative";
import { cn } from "../lib/utils";
import { clock, delta, elementLabel, value, worst } from "../format";

const PILL: Record<string, string> = {
	view: "bg-slate-100 text-slate-600",
	tap: "bg-blue-100 text-blue-700",
	submit: "bg-emerald-100 text-emerald-700",
};

export function EventCard(props: { card: Card; reply: Reply | null; selected: boolean; onSelect(): void; onJumpVisit(index: number): void }) {
	const { card, reply } = props;
	const e = card.event;
	const shell = e.owner === "shell";
	const severity = worst(card.findings);
	const props_ = Object.entries(e.props);

	return (
		<div id={`card-${card.id}`} className={cn("flex items-start gap-3", shell && "flex-row-reverse")}>
			<div className={cn("w-16 shrink-0 pt-2 font-mono text-[10px] leading-4 text-muted-foreground tabular-nums", shell ? "text-left" : "text-right")}>
				<div>{clock(e.at).slice(0, 8)}</div>
				<div className="text-violet-600">#{card.id}</div>
				<div>{delta(card.sincePrevMs)}</div>
			</div>
			<button
				onClick={props.onSelect}
				className={cn(
					"relative min-w-0 max-w-xl flex-1 overflow-hidden rounded-xl border bg-white px-3 py-2 text-left shadow-sm transition-all hover:border-slate-300 hover:shadow",
					shell && "bg-slate-50",
					props.selected && "border-violet-500 ring-2 ring-violet-500/30",
				)}
			>
				{severity && (
					<span
						className={cn(
							"absolute inset-y-0 w-1",
							shell ? "right-0" : "left-0",
							severity === "error" ? "bg-rose-500" : severity === "warn" ? "bg-amber-400" : "bg-sky-300",
						)}
					/>
				)}
				<div className="flex items-center gap-2">
					<span className={cn("rounded px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide", PILL[e.interaction])}>{e.interaction}</span>
					{shell && <span className="rounded bg-slate-200 px-1.5 py-0.5 text-[10px] font-medium text-slate-600">shell</span>}
					<span className="truncate font-mono text-[13px] font-semibold">{elementLabel(card)}</span>
					<span className="ml-auto flex items-center gap-1.5">
						{e.domain !== "none" && <span className="rounded-full border px-2 py-0.5 text-[10px] text-muted-foreground">{e.domain}</span>}
						{card.findings.length > 0 && (
							<span
								className={cn(
									"flex h-4 min-w-4 items-center justify-center rounded-full px-1 text-[10px] font-semibold text-white",
									severity === "error" ? "bg-rose-500" : severity === "warn" ? "bg-amber-500" : "bg-sky-400",
								)}
							>
								{card.findings.length}
							</span>
						)}
					</span>
				</div>
				{props_.length > 0 && (
					<div className="mt-1.5 flex flex-wrap gap-1">
						{props_.slice(0, 3).map(([k, v]) => (
							<span key={k} className="rounded bg-secondary px-1.5 py-0.5 font-mono text-[11px]">
								<span className="text-muted-foreground">{k}</span> {typeof v === "boolean" ? (v ? "✓" : "✗") : value(v)}
							</span>
						))}
						{props_.length > 3 && <span className="px-1 py-0.5 font-mono text-[11px] text-muted-foreground">+{props_.length - 3}</span>}
					</div>
				)}
				{reply?.kind === "jump" && (
					<div
						onClick={(ev) => {
							ev.stopPropagation();
							if (reply.toVisit !== null) props.onJumpVisit(reply.toVisit);
						}}
						className={cn(
							"mt-1.5 flex items-center gap-1 text-xs font-medium",
							reply.fulfilled ? "text-violet-700 hover:underline" : "text-rose-600 line-through",
						)}
					>
						<ArrowRight className="h-3.5 w-3.5" /> navigates {reply.target === "previous" ? "previous" : screenKey(reply.target)}
					</div>
				)}
				{reply?.kind === "reroot" && (
					<div className="mt-1.5 flex items-center gap-1 text-xs text-muted-foreground">
						<RotateCw className="h-3 w-3" /> reroots
					</div>
				)}
				{reply?.kind === "thread" && (
					<div className="mt-1.5 flex items-center gap-1 text-xs text-muted-foreground">
						<CornerDownRight className="h-3.5 w-3.5" /> presents <span className="font-mono text-foreground">{reply.presentation.name}</span>
						{reply.presentation.mode && <span className="rounded bg-secondary px-1 font-mono">{reply.presentation.mode}</span>}
					</div>
				)}
			</button>
		</div>
	);
}
