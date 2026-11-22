/**
 * The chat. Every layout decision is a rendering of a narrative type: Visit → divider,
 * card → EventCard (+ its reply), thread → indented rail, views → collapsed run,
 * context → centered system line.
 */

import { Layers, Settings2 } from "lucide-react";
import { useState } from "react";
import { screenKey } from "../../model";
import type { EventCard as Card, Presentation, StreamItem, Visit } from "../../narrative";
import { cn } from "../lib/utils";
import { clock, elementLabel, value } from "../format";
import { EventCard } from "./EventCard";

const RAILS = ["border-violet-300", "border-sky-300", "border-emerald-300", "border-amber-300", "border-pink-300", "border-teal-300"];
const railFor = (name: string) => RAILS[[...name].reduce((a, c) => a + c.charCodeAt(0), 0) % RAILS.length];

export interface StreamProps {
	visits: Visit[];
	selected: string | null;
	onSelect(cardId: string): void;
	hideViews: boolean;
}

export function Stream(props: StreamProps) {
	const jumpVisit = (index: number) => document.getElementById(`visit-${index}`)?.scrollIntoView({ behavior: "smooth", block: "start" });
	return (
		<div className="space-y-6 px-8 py-6">
			{props.visits.map((visit) => (
				<section key={visit.index} id={`visit-${visit.index}`} className="space-y-3">
					<VisitDivider visit={visit} />
					<Items items={visit.items} {...props} onJumpVisit={jumpVisit} />
				</section>
			))}
		</div>
	);
}

function VisitDivider(props: { visit: Visit }) {
	const { visit } = props;
	const arrival =
		visit.arrival.kind === "launch"
			? "launch"
			: visit.arrival.kind === "unexplained"
				? "unexplained"
				: visit.arrival.kind === "tab"
					? `tab · #${visit.arrival.via}`
					: visit.arrival.kind === "popped"
						? `back · #${visit.arrival.via}`
						: `via #${visit.arrival.via}`;
	return (
		<div className="sticky top-0 z-10 -mx-2 flex items-center gap-3 bg-slate-50/95 px-2 py-1.5 backdrop-blur">
			<span className="font-mono text-[10px] text-muted-foreground">{clock(visit.startedAt).slice(0, 8)}</span>
			<div className="h-px flex-1 bg-border" />
			<span className="flex items-center gap-1.5 rounded-full border bg-white px-3 py-1 font-mono text-xs font-semibold shadow-sm">
				<span className="h-1.5 w-1.5 rounded-full bg-violet-500" />
				{screenKey(visit.screen)}
			</span>
			<div className="h-px flex-1 bg-border" />
			<span className={cn("text-[11px]", visit.arrival.kind === "unexplained" ? "font-medium text-amber-600" : "text-muted-foreground")}>{arrival}</span>
		</div>
	);
}

function Items(props: StreamProps & { items: StreamItem[]; onJumpVisit(index: number): void }) {
	return (
		<div className="space-y-2">
			{props.items.map((item, i) => {
				switch (item.kind) {
					case "card":
						if (props.hideViews && item.card.event.interaction === "view" && !item.card.findings.length) return null;
						return (
							<div key={item.card.id} className="space-y-2">
								<EventCard
									card={item.card}
									reply={item.reply}
									selected={props.selected === item.card.id}
									onSelect={() => props.onSelect(item.card.id)}
									onJumpVisit={props.onJumpVisit}
								/>
								{item.reply?.kind === "thread" && <Thread presentation={item.reply.presentation} {...props} />}
							</div>
						);
					case "views":
						if (props.hideViews && !item.cards.some((c) => c.findings.length)) return null;
						return <ViewRun key={item.cards[0]!.id} cards={item.cards} {...props} />;
					case "context":
						return (
							<div key={`ctx-${item.change.seq}`} className="flex justify-center">
								<span className="flex items-center gap-1.5 rounded-full bg-amber-50 px-3 py-1 font-mono text-[11px] text-amber-800 ring-1 ring-amber-200">
									<Settings2 className="h-3 w-3" /> {item.change.field}: {value(item.change.from)} → {value(item.change.to)}
									<span className="text-amber-600">#{item.change.seq}</span>
								</span>
							</div>
						);
					case "implicit":
						return <Thread key={`imp-${i}`} presentation={item.presentation} {...props} />;
				}
			})}
		</div>
	);
}

function Thread(props: StreamProps & { presentation: Presentation; onJumpVisit(index: number): void }) {
	const p = props.presentation;
	return (
		<div className={cn("ml-[5.5rem] border-l-2 pl-4", railFor(p.name))}>
			<div className="mb-1.5 flex items-center gap-1.5 text-[11px] text-muted-foreground">
				<Layers className="h-3 w-3" />
				<span className="font-mono font-medium text-foreground">{p.name}</span>
				{p.mode && <span className="rounded bg-secondary px-1 font-mono">{p.mode}</span>}
				{p.openedBy === null && <span className="font-medium text-amber-600">opened implicitly</span>}
			</div>
			<Items {...props} items={p.items} />
		</div>
	);
}

function ViewRun(props: StreamProps & { cards: Card[]; onJumpVisit(index: number): void }) {
	const [open, setOpen] = useState(false);
	const first = props.cards[0]!;
	if (open) {
		return (
			<div className="space-y-2">
				{props.cards.map((card) => (
					<EventCard key={card.id} card={card} reply={null} selected={props.selected === card.id} onSelect={() => props.onSelect(card.id)} onJumpVisit={props.onJumpVisit} />
				))}
				<button onClick={() => setOpen(false)} className="ml-[5.5rem] text-[11px] text-muted-foreground hover:text-foreground">
					collapse
				</button>
			</div>
		);
	}
	const flagged = props.cards.some((c) => c.findings.length);
	return (
		<div className="flex items-start gap-3">
			<div className="w-16 shrink-0 pt-2 text-right font-mono text-[10px] leading-4 text-muted-foreground">
				<div>{clock(first.event.at).slice(0, 8)}</div>
				<div className="text-violet-600">
					#{first.id}–{props.cards[props.cards.length - 1]!.id}
				</div>
			</div>
			<button
				onClick={() => setOpen(true)}
				className="relative max-w-xl flex-1 rounded-xl border bg-white px-3 py-2 text-left shadow-[0_3px_0_-1px_white,0_4px_0_-1px_hsl(214.3_31.8%_91.4%),0_6px_0_-2px_white,0_7px_0_-2px_hsl(214.3_31.8%_91.4%)] hover:border-slate-300"
			>
				<div className="flex items-center gap-2">
					<span className="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-slate-600">view ×{props.cards.length}</span>
					<span className="font-mono text-[13px] font-semibold">{elementLabel(first)}</span>
					{flagged && <span className="ml-auto h-2 w-2 rounded-full bg-rose-500" />}
				</div>
				<div className="mt-1 text-[11px] text-muted-foreground">impressions collapsed · click to expand</div>
			</button>
		</div>
	);
}
