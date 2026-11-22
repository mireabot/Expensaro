/**
 * Top of a session. Stat tiles (Navattic "Session summary"), then a 2-column grid of context cards
 * (Sentry "Contexts") with stacked label-over-value rows (Maze "Session details"). Mutable fields
 * show the current value plus a "changed ×N" badge that expands into a mini timeline.
 */

import { AlertTriangle, ChevronDown, Info, OctagonAlert } from "lucide-react";
import { useState } from "react";
import type { FieldChange, Finding, Session } from "../../narrative";
import { cn } from "../lib/utils";
import { clock, duration, value } from "../format";

const CARDS: Array<{ title: string; rows: string[] }> = [
	{ title: "App", rows: ["app_version", "build", "spec_version", "schema_version"] },
	{ title: "Device", rows: ["platform", "os_version", "device_class", "reduce_motion"] },
	{ title: "Locale", rows: ["locale", "time_zone"] },
	{ title: "Settings", rows: ["currency", "notifications_enabled", "launch_root"] },
];

export function SessionHeader(props: { session: Session; onJump(seq: number): void }) {
	const { session } = props;
	const { stats, context } = session;
	const sessionFindings = session.findings.filter((f) => f.card === null);
	const tone = stats.findings.error ? "error" : stats.findings.warn ? "warn" : null;

	return (
		<section className="space-y-4 border-b bg-white px-8 py-6">
			<div className="flex items-baseline gap-3">
				<h1 className="font-mono text-lg font-semibold">{session.id}</h1>
				<span className="rounded bg-violet-100 px-1.5 py-0.5 font-mono text-[11px] text-violet-700">{session.source}</span>
				{context.init && <span className="text-xs text-muted-foreground">started {context.init.startedAt.toLocaleString([], { hour12: false })}</span>}
			</div>

			<div className="grid grid-cols-5 gap-3">
				<Stat label="Duration" value={duration(stats.durationMs)} />
				<Stat label="Events" value={String(stats.events)} />
				<Stat label="Screens" value={`${stats.screens}`} hint={`${stats.visits} visits`} />
				<Stat label="Presentations" value={String(stats.presentations)} />
				<Stat
					label="Findings"
					value={String(stats.findings.error + stats.findings.warn + stats.findings.info)}
					hint={`${stats.findings.error} error · ${stats.findings.warn} warn · ${stats.findings.info} info`}
					tone={tone}
				/>
			</div>

			{context.init ? (
				<div className="grid grid-cols-2 gap-3 xl:grid-cols-4">
					{CARDS.map((card) => (
						<div key={card.title} className="rounded-lg border bg-white p-3">
							<div className="mb-2 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">{card.title}</div>
							<div className="space-y-2">
								{card.rows.map((row) => (
									<ContextRow
										key={row}
										label={row}
										value={value((context.current as unknown as Record<string, string | boolean>)[row])}
										changes={context.changes.filter((c) => c.field === row)}
										onJump={props.onJump}
									/>
								))}
							</div>
						</div>
					))}
				</div>
			) : (
				<div className="flex items-center gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-sm text-rose-700">
					<OctagonAlert className="h-4 w-4" /> No session_init received; showing events only.
				</div>
			)}

			{sessionFindings.length > 0 && (
				<div className="rounded-lg border">
					{sessionFindings.map((f, i) => (
						<FindingRow key={i} finding={f} onJump={props.onJump} />
					))}
				</div>
			)}
		</section>
	);
}

function Stat(props: { label: string; value: string; hint?: string; tone?: "error" | "warn" | null }) {
	return (
		<div
			className={cn(
				"rounded-lg border bg-white px-4 py-3",
				props.tone === "error" && "border-rose-200 bg-rose-50",
				props.tone === "warn" && "border-amber-200 bg-amber-50",
			)}
		>
			<div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">{props.label}</div>
			<div className={cn("mt-1 text-2xl font-semibold tabular-nums", props.tone === "error" && "text-rose-700", props.tone === "warn" && "text-amber-700")}>
				{props.value}
			</div>
			{props.hint && <div className="mt-0.5 text-[11px] text-muted-foreground">{props.hint}</div>}
		</div>
	);
}

function ContextRow(props: { label: string; value: string; changes: FieldChange[]; onJump(seq: number): void }) {
	const [open, setOpen] = useState(false);
	return (
		<div>
			<div className="text-[11px] text-muted-foreground">{props.label}</div>
			<div className="flex items-center gap-2">
				<span className="font-mono text-sm">{props.value}</span>
				{props.changes.length > 0 && (
					<button
						onClick={() => setOpen(!open)}
						className="flex items-center gap-0.5 rounded bg-amber-100 px-1.5 py-0.5 text-[10px] font-medium text-amber-800 hover:bg-amber-200"
					>
						changed ×{props.changes.length}
						<ChevronDown className={cn("h-3 w-3 transition-transform", open && "rotate-180")} />
					</button>
				)}
			</div>
			{open && (
				<div className="mt-1 space-y-0.5 border-l-2 border-amber-200 pl-2">
					{props.changes.map((c) => (
						<button key={c.seq} onClick={() => props.onJump(c.seq)} className="block font-mono text-[11px] text-muted-foreground hover:text-foreground">
							{value(c.from)} → {value(c.to)} <span className="text-violet-600">#{c.seq}</span> · {clock(c.at)}
						</button>
					))}
				</div>
			)}
		</div>
	);
}

export function FindingRow(props: { finding: Finding; onJump?(seq: number): void }) {
	const { finding } = props;
	const Icon = finding.severity === "error" ? OctagonAlert : finding.severity === "warn" ? AlertTriangle : Info;
	return (
		<div className="flex items-start gap-2 border-b px-3 py-2 text-sm last:border-b-0">
			<Icon
				className={cn(
					"mt-0.5 h-4 w-4 shrink-0",
					finding.severity === "error" && "text-rose-600",
					finding.severity === "warn" && "text-amber-600",
					finding.severity === "info" && "text-sky-600",
				)}
			/>
			<div className="min-w-0">
				<span className="font-mono text-xs font-medium">{finding.code}</span>
				{finding.seq !== null && (
					<button onClick={() => props.onJump?.(finding.seq!)} className="ml-1.5 font-mono text-xs text-violet-600 hover:underline">
						#{finding.seq}
					</button>
				)}
				<div className="text-xs text-muted-foreground">{finding.detail}</div>
			</div>
		</div>
	);
}
