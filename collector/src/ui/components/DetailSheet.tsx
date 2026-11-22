/**
 * The slider. Header from fal's request sheet ("12 / 86" with ↑/↓) plus Amplitude's Info/Raw toggle
 * and Copy URL; title + one-line description and icon-rail sections When / Where / What / Props
 * from Railway's audit drawer; "Context at #seq" as Sentry-style mini cards.
 */

import { Check, ChevronDown, ChevronUp, Clock, Copy, Link2, ListTree, MapPin, Settings2, TriangleAlert, X, Zap } from "lucide-react";
import { useState } from "react";
import { formatEffect } from "../../model";
import { contextAt, type Session } from "../../narrative";
import { cn } from "../lib/utils";
import { clock, delta, describe, elementLabel, value } from "../format";
import { FindingRow } from "./SessionHeader";

export function DetailSheet(props: { session: Session; cardId: string; onNavigate(cardId: string): void; onClose(): void }) {
	const { session } = props;
	const [tab, setTab] = useState<"info" | "raw">("info");
	const index = session.cards.findIndex((c) => c.id === props.cardId);
	const card = session.cards[index];
	if (!card) return null;
	const e = card.event;
	const prev = session.cards[index - 1];
	const next = session.cards[index + 1];
	const at = contextAt(session.context, e.seq);
	const current = session.context.current;

	return (
		<aside className="fixed inset-y-0 right-0 z-30 flex w-[460px] flex-col border-l bg-white shadow-2xl">
			<header className="flex items-center gap-2 border-b px-4 py-2.5">
				<span className="font-mono text-xs tabular-nums text-muted-foreground">
					{index + 1} / {session.cards.length}
				</span>
				<IconButton label="Previous (k)" disabled={!prev} onClick={() => prev && props.onNavigate(prev.id)}>
					<ChevronUp className="h-4 w-4" />
				</IconButton>
				<IconButton label="Next (j)" disabled={!next} onClick={() => next && props.onNavigate(next.id)}>
					<ChevronDown className="h-4 w-4" />
				</IconButton>
				<div className="ml-2 flex rounded-md bg-secondary p-0.5 text-xs">
					{(["info", "raw"] as const).map((t) => (
						<button key={t} onClick={() => setTab(t)} className={cn("rounded px-2.5 py-1 font-medium capitalize", tab === t ? "bg-white shadow-sm" : "text-muted-foreground")}>
							{t}
						</button>
					))}
				</div>
				<div className="ml-auto flex items-center gap-1">
					<CopyButton text={location.href} label="Copy URL" icon={<Link2 className="h-4 w-4" />} />
					<IconButton label="Close (Esc)" onClick={props.onClose}>
						<X className="h-4 w-4" />
					</IconButton>
				</div>
			</header>

			<div className="flex-1 overflow-y-auto">
				<div className="border-b px-5 py-4">
					<div className="font-mono text-[15px] font-semibold">{elementLabel(card)}</div>
					<div className="mt-0.5 break-all font-mono text-xs text-muted-foreground">{card.path}</div>
					<div className="mt-1.5 text-sm text-muted-foreground">{describe(card)}</div>
				</div>

				{tab === "raw" ? (
					<div className="p-5">
						<div className="mb-2 flex items-center justify-between text-xs text-muted-foreground">
							<span>
								line {card.line} · received {new Date(card.receivedAt).toLocaleTimeString([], { hour12: false })}
							</span>
							<CopyButton text={JSON.stringify(card.raw, null, 2)} label="Copy JSON" icon={<Copy className="h-3.5 w-3.5" />} />
						</div>
						<pre className="overflow-x-auto rounded-lg bg-slate-900 p-4 font-mono text-xs leading-relaxed text-slate-100">{JSON.stringify(card.raw, null, 2)}</pre>
					</div>
				) : (
					<div className="space-y-5 px-5 py-4">
						{card.findings.length > 0 && (
							<Section icon={<TriangleAlert className="h-3.5 w-3.5" />} title="Findings" tone="rose">
								<div className="rounded-lg border">
									{card.findings.map((f, i) => (
										<FindingRow key={i} finding={f} />
									))}
								</div>
							</Section>
						)}
						<Section icon={<Clock className="h-3.5 w-3.5" />} title="When">
							<Rows
								rows={[
									["time", clock(e.at)],
									["seq", `#${e.seq}`],
									["since previous", delta(card.sincePrevMs) || "—"],
									["since start", delta(card.sinceStartMs) || "—"],
								]}
							/>
						</Section>
						<Section icon={<MapPin className="h-3.5 w-3.5" />} title="Where">
							<Rows
								rows={[
									["owner", e.owner],
									["layer", e.layer],
									["screen", e.screen],
									["component", e.component ?? "—"],
									["element", e.element ?? "—"],
									["host", e.host ?? "—"],
								]}
							/>
							{card.chain.length > 0 && (
								<div className="mt-2 flex flex-wrap items-center gap-1 font-mono text-[11px] text-muted-foreground">
									<ListTree className="h-3 w-3" /> {e.screen}
									{card.chain.map((name) => (
										<span key={name}>› {name}</span>
									))}
								</div>
							)}
						</Section>
						<Section icon={<Zap className="h-3.5 w-3.5" />} title="What">
							<Rows
								rows={[
									["interaction", e.interaction],
									["effect", formatEffect(e.effect)],
									["domain", e.domain],
								]}
							/>
						</Section>
						<Section icon={<ListTree className="h-3.5 w-3.5" />} title={`Props (${Object.keys(e.props).length})`}>
							{Object.keys(e.props).length ? (
								<Rows rows={Object.entries(e.props).map(([k, v]) => [k, value(v)])} />
							) : (
								<div className="text-xs text-muted-foreground">No props</div>
							)}
						</Section>
						{at && (
							<Section icon={<Settings2 className="h-3.5 w-3.5" />} title={`Context at #${e.seq}`}>
								<div className="grid grid-cols-2 gap-2">
									{(["currency", "notifications_enabled", "launch_root", "app_version", "os_version", "locale"] as const).map((k) => {
										const changed = current && current[k] !== at[k];
										return (
											<div key={k} className="rounded-md border px-2.5 py-1.5">
												<div className="flex items-center gap-1 text-[10px] text-muted-foreground">
													{k}
													{changed && <span className="h-1.5 w-1.5 rounded-full bg-amber-500" title="differs from the current value" />}
												</div>
												<div className="font-mono text-xs">{value(at[k])}</div>
											</div>
										);
									})}
								</div>
							</Section>
						)}
					</div>
				)}
			</div>
		</aside>
	);
}

function Section(props: { icon: React.ReactNode; title: string; tone?: "rose"; children: React.ReactNode }) {
	return (
		<section className="flex gap-3">
			<div className="flex flex-col items-center">
				<span className={cn("flex h-6 w-6 items-center justify-center rounded-full", props.tone === "rose" ? "bg-rose-100 text-rose-600" : "bg-violet-100 text-violet-600")}>
					{props.icon}
				</span>
				<span className="mt-1 w-px flex-1 bg-border" />
			</div>
			<div className="min-w-0 flex-1 pb-1">
				<div className="mb-2 text-xs font-semibold">{props.title}</div>
				{props.children}
			</div>
		</section>
	);
}

function Rows(props: { rows: Array<[string, string]> }) {
	return (
		<div className="overflow-hidden rounded-lg border bg-slate-50/60">
			{props.rows.map(([k, v]) => (
				<div key={k} className="flex items-baseline gap-3 border-b px-3 py-1.5 text-xs last:border-b-0">
					<span className="w-28 shrink-0 text-muted-foreground">{k}</span>
					<span className="min-w-0 break-all font-mono">{v}</span>
				</div>
			))}
		</div>
	);
}

function IconButton(props: { label: string; disabled?: boolean; onClick(): void; children: React.ReactNode }) {
	return (
		<button
			title={props.label}
			disabled={props.disabled}
			onClick={props.onClick}
			className="rounded-md p-1.5 text-muted-foreground hover:bg-secondary hover:text-foreground disabled:opacity-30 disabled:hover:bg-transparent"
		>
			{props.children}
		</button>
	);
}

function CopyButton(props: { text: string; label: string; icon: React.ReactNode }) {
	const [done, setDone] = useState(false);
	return (
		<IconButton
			label={props.label}
			onClick={async () => {
				await navigator.clipboard.writeText(props.text);
				setDone(true);
				setTimeout(() => setDone(false), 1500);
			}}
		>
			{done ? <Check className="h-4 w-4 text-emerald-600" /> : props.icon}
		</IconButton>
	);
}
