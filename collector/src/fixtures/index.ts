import broken from "./scenarios/broken";
import firstRun from "./scenarios/first-run";
import homeDay from "./scenarios/home-day";
import type { Fixture } from "./scenario";

export const FIXTURES: readonly Fixture[] = [firstRun, homeDay, broken];

export function fixtureByName(name: string): Fixture | undefined {
	return FIXTURES.find((f) => f.name === name);
}
