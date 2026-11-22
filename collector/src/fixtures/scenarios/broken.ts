/**
 * Deliberately wrong session: every expectation below names the seq and code narrate() must report.
 */
import { scenario } from "../scenario";

const event = (seq: number, props: Record<string, string | number | boolean>, extra: Record<string, unknown> = {}) => ({
	kind: "event",
	session_id: "fixture-broken",
	seq,
	timestamp: "2026-11-22T09:00:09.000Z",
	owner: "screen",
	layer: "home",
	screen: "transactions",
	component: "toolbar",
	element: "transaction_form",
	interaction: "tap",
	effect: "stays",
	domain: "transaction",
	props,
	...extra,
});

export default scenario(
	{
		name: "broken",
		summary: "A session with mistakes the collector must catch",
		expect: [
			{ seq: 3, code: "session_field_on_event" },
			{ seq: 4, code: "free_text_suspect" },
			{ seq: 5, code: "unfulfilled_navigation" },
			{ seq: 11, code: "missing_host" },
			{ seq: 12, code: "seq_retry" },
			{ seq: 12, code: "seq_conflict" },
			{ seq: 14, code: "seq_gap" },
			{ seq: 14, code: "non_snake_id" },
			{ seq: 15, code: "unexplained_arrival" },
			{ seq: null, code: "malformed" },
		],
	},
	{},
	(s) => {
		s.on("home.dashboard");
		s.at("budget").view("balance", { domain: "budget", props: { budget_left_bucket: "250_500" } });
		s.at("transactions").view("transaction_card", { domain: "transaction", props: { position: 0, currency: "USD" } });
		s.at("transactions").view("transaction_card", { domain: "transaction", props: { position: 1, category: "Coffee with Anna" }, afterMs: 90 });
		s.at("payments").tap("all", { effect: "navigates(home.payments)", domain: "recurring_payment", props: { payment_count: 1 } });

		s.on("home.transactions");
		s.at("toolbar").tap("transaction_form", { effect: "presents(transaction_form, create)", domain: "transaction" });
		s.within("transaction_form", (f) => {
			f.tap("category", { effect: "presents(category_picker)", domain: "category" });
		});
		s.raw(event(11, { category: "groceries", category_section: "food" }, { component: "category_picker", element: "row", domain: "category" }));
		s.raw(event(12, {}));
		s.raw(event(12, {}));
		s.raw(event(12, { position: 2 }));
		s.reuseSeq(14);
		s.at("Toolbar").tap("transaction_form", { domain: "transaction" });

		s.on("home.payments");
		s.at("list").view("payment_row", { domain: "recurring_payment", props: { position: 0 } });
		s.raw({ kind: "event", session_id: "fixture-broken", seq: "twelve" });
	},
);
