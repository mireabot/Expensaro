/**
 * A returning user's session: dashboard impressions, a daily preset from the shell accessory,
 * a transaction detail with a note and deletion (navigates previous), the payments calendar
 * (reroots), a tab switch to goals, and a currency change in settings (session_update).
 */
import { scenario } from "../scenario";

const card = (position: number, transaction_type: string, category: string, amount_bucket: string) => ({
	position,
	transaction_type,
	category,
	amount_bucket,
});

export default scenario(
	{ name: "home-day", summary: "Returning user: detail, delete, calendar, goals tab, currency", expect: [] },
	{},
	(s) => {
		s.on("home.dashboard");
		s.at("budget").view("balance", { domain: "budget", props: { budget_left_bucket: "500_1k" }, afterMs: 600 }); // #18
		const payments = s.at("payments");
		payments.view("payment_card", { domain: "recurring_payment", props: { position: 0, periodicity: "monthly", is_due: false, days_until_due: 6, has_reminder: true, amount_bucket: "10_25", category: "subscription" } }); // #23
		payments.view("payment_card", { domain: "recurring_payment", props: { position: 1, periodicity: "yearly", is_due: false, days_until_due: 41, has_reminder: false, amount_bucket: "100_250", category: "bills" }, afterMs: 120 });
		const txs = s.at("transactions");
		txs.view("transaction_card", { domain: "transaction", props: card(0, "debit", "groceries", "25_50") }); // #28
		txs.view("transaction_card", { domain: "transaction", props: card(1, "debit", "going_out", "10_25"), afterMs: 90 });
		txs.view("transaction_card", { domain: "transaction", props: card(2, "credit", "other", "100_250"), afterMs: 90 });

		s.shell("accessory").tap("menu", { domain: "none", props: { style: "add", is_expanded: true }, afterMs: 2600 }); // #3
		s.shell("accessory").tap("daily_preset", { domain: "transaction", props: { preset: true, position: 0, amount_bucket: "under_10", category: "going_out", succeeded: true }, afterMs: 1100 }); // #6

		txs.tap("transaction_card", { effect: "navigates(home.transaction_detail)", domain: "transaction", props: card(0, "debit", "groceries", "25_50"), afterMs: 2400 }); // #29
		s.on("home.transaction_detail");
		s.at("header").view("summary", { domain: "transaction", props: { transaction_type: "debit", category: "groceries", amount_bucket: "25_50", has_note: false } }); // #82
		s.at("insights").view("category_card", { domain: "transaction", props: { is_locked: false, category: "groceries" } }); // #84
		s.at("note").tap("card", { effect: "presents(note_sheet)", domain: "transaction", props: { has_note: false }, afterMs: 1800 }); // #83
		s.within("note_sheet", (n) => {
			n.submit("done", { domain: "transaction", props: { note_length: 18, has_note: true }, afterMs: 5200 }); // #91
		});
		s.shell("accessory").tap("transaction_deletion", { effect: "presents(transaction_deletion)", domain: "transaction", props: { transaction_type: "debit" }, afterMs: 2100 }); // #11
		s.within("transaction_deletion", (d) => {
			d.tap("primary", { effect: "navigates(previous)", domain: "transaction", props: { transaction_type: "debit", amount_bucket: "25_50" }, afterMs: 1300 }); // #93
		});

		s.on("home.dashboard");
		payments.tap("all", { effect: "navigates(home.payments)", domain: "recurring_payment", props: { payment_count: 2 }, afterMs: 1900 }); // #22
		s.on("home.payments");
		const calendar = s.at("calendar");
		calendar.tap("next_month", { effect: "reroots", domain: "recurring_payment", props: { month_offset: 1 }, afterMs: 1500 }); // #98
		calendar.tap("day", { effect: "reroots", domain: "recurring_payment", props: { has_payments: true, day_offset: 9 }, afterMs: 1200 }); // #99
		s.at("list").view("payment_row", { domain: "recurring_payment", props: { position: 0, periodicity: "monthly", is_due: false, has_reminder: true, amount_bucket: "10_25", category: "subscription" } }); // #100
		s.at("nav").tap("back", { effect: "navigates(previous)", domain: "none", afterMs: 1700 }); // #95

		s.on("home.dashboard");
		s.at("toolbar").tap("settings", { effect: "navigates(settings.root)", domain: "none", afterMs: 1400 }); // #17
		s.on("settings.root");
		s.at("menu").tap("general", { effect: "navigates(settings.app)", domain: "account", afterMs: 1100 }); // #157
		s.on("settings.app");
		s.at("menu").tap("currency", { effect: "navigates(settings.currency)", domain: "account", afterMs: 900 }); // #163
		s.on("settings.currency");
		s.at("list").tap("currency_cell", { domain: "account", props: { is_changed: true }, afterMs: 2300 }); // #165
		s.update("currency", "GBP");
		s.at("nav").tap("back", { effect: "navigates(previous)", domain: "none", afterMs: 800 }); // #164
		s.on("settings.app");
		s.at("nav").tap("back", { effect: "navigates(previous)", domain: "none", afterMs: 700 }); // #162
		s.on("settings.root");

		s.shell("tab_bar").tap("tab", { domain: "none", props: { tab: "goals", is_reselect: false, stack_depth: 1 }, afterMs: 1500 }); // #1
		s.on("goals.list");
		s.at("summary").view("total", { domain: "goal", props: { total_saved_bucket: "1k_2_5k", goal_count: 2 } }); // #112
		s.at("list").view("goal_card", { domain: "goal", props: { position: 0, goal_status: "active", progress: 0.42, days_left: 63, amount_bucket: "2_5k_5k" } }); // #113
		s.at("list").view("goal_card", { domain: "goal", props: { position: 1, goal_status: "completed", progress: 1, days_left: 0, amount_bucket: "500_1k" }, afterMs: 90 });
	},
);
