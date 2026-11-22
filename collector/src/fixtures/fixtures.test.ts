import { describe, expect, test } from "bun:test";
import type { StoredRecord } from "../model";
import { narrate } from "../narrative";
import { FIXTURES } from ".";

const stored = (records: unknown[]): StoredRecord[] =>
	records.map((body, line) => ({ line, receivedAt: "2026-11-22T09:00:00.000Z", source: "test", body }));

const key = (f: { seq: number | null; code: string }) => `${f.seq ?? "-"}:${f.code}`;

describe("fixtures narrate to exactly their expected findings", () => {
	for (const fixture of FIXTURES) {
		test(fixture.name, () => {
			const session = narrate(stored(fixture.records), `fixture-${fixture.name}`);
			const actual = session.findings.map(key).sort();
			expect(actual).toEqual(fixture.expect.map(key).sort());
		});
	}
});

describe("narrative shape", () => {
	test("first-run threads the category chain under the form with hosts", () => {
		const session = narrate(stored(FIXTURES[0]!.records), "fixture-first-run");
		expect(session.visits.map((v) => `${v.screen.layer}.${v.screen.screen}:${v.arrival.kind}`)).toEqual([
			"onboarding.intro:launch",
			"home.dashboard:navigated",
		]);
		const row = session.cards.find((c) => c.path.endsWith("category_picker.row"))!;
		expect(row.chain).toEqual(["transaction_form", "category_picker"]);
		expect(row.event.host).toBe("transaction_form");
		expect(session.context.current?.currency).toBe("EUR");
		expect(session.context.changes.map((c) => c.field)).toEqual(["notifications_enabled", "currency", "launch_root"]);
	});

	test("home-day resolves pops and tab arrivals", () => {
		const session = narrate(stored(FIXTURES[1]!.records), "fixture-home-day");
		const arrivals = session.visits.map((v) => `${v.screen.screen}:${v.arrival.kind}`);
		expect(arrivals).toContain("dashboard:popped");
		expect(arrivals[arrivals.length - 1]).toBe("list:tab");
	});
});
