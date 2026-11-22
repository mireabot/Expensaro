/**
 * Fresh install: onboarding pager, permissions with currency picker, finish (session switch plus
 * session_update), budget creation, then a first transaction through the
 * category_picker > category_form > section_picker host chain.
 */
import { scenario } from "../scenario";

export default scenario(
	{ name: "first-run", summary: "Onboarding, then the first transaction with a new category", expect: [] },
	{ launch_root: "onboarding", currency: "", notifications_enabled: false },
	(s) => {
		s.on("onboarding.intro");
		const pager = s.at("pager");
		pager.view("feature_page", { domain: "none", props: { feature: "custom_categories", position: 0 }, afterMs: 900 }); // #184
		pager.view("feature_page", { domain: "none", props: { feature: "goal_success_rate", position: 1 }, afterMs: 2200 });
		pager.view("feature_page", { domain: "none", props: { feature: "payment_alerts", position: 2 }, afterMs: 2100 });
		s.at("footer").tap("start", { effect: "presents(permissions)", domain: "none", props: { pages_seen: 3 }, afterMs: 1500 }); // #185
		s.within("permissions", (p) => {
			p.view("system_prompt", { domain: "account", props: { granted: true }, afterMs: 1800 }); // #186
			p.tap("notifications", { domain: "account", props: { is_on: true } }); // #187
			p.tap("currency", { effect: "presents(currency_picker)", domain: "account", afterMs: 1200 }); // #188
			p.within("currency_picker", (c) => {
				c.tap("currency_cell", { domain: "account", props: { is_changed: true }, afterMs: 2600 }); // #190
			});
			p.submit("finish", { effect: "navigates(home.dashboard)", domain: "account", props: { notifications_on: true }, afterMs: 1400 }); // #189
		});
		s.update("notifications_enabled", true);
		s.update("currency", "EUR");
		s.wait(2000);
		s.update("launch_root", "home");

		s.on("home.dashboard");
		s.at("budget").view("empty_cta", { domain: "budget" }); // #20
		s.at("payments").view("empty_cta", { domain: "recurring_payment", props: { is_enabled: false } }); // #25
		s.at("transactions").view("empty_cta", { domain: "transaction", props: { is_enabled: false } }); // #30
		s.at("budget").tap("empty_cta", { effect: "presents(budget_form, create)", domain: "budget", afterMs: 2400 }); // #21
		s.within("budget_form", (b) => {
			b.submit("done", { effect: "presents(budget_confirm)", domain: "budget", props: { amount_bucket: "1k_2_5k", is_valid: true }, afterMs: 3800 }); // #32
			b.within("budget_confirm", (c) => {
				c.tap("primary", { domain: "budget", props: { amount_bucket: "1k_2_5k" }, afterMs: 900 }); // #35
			});
		});
		s.at("budget").view("balance", { domain: "budget", props: { budget_left_bucket: "1k_2_5k" }, afterMs: 1100 }); // #18
		s.at("transactions").tap("empty_cta", { effect: "presents(transaction_form, create)", domain: "transaction", afterMs: 1600 }); // #31
		s.within("transaction_form", (f) => {
			f.tap("category", { effect: "presents(category_picker)", domain: "category", afterMs: 2100 }); // #38
			f.within("category_picker", (cp) => {
				cp.tap("category_form", { effect: "presents(category_form)", domain: "category", afterMs: 1900 }); // #56
				cp.within("category_form", (cf) => {
					cf.tap("section", { effect: "presents(section_picker)", domain: "category", props: { entry: "sheet" }, afterMs: 2500 }); // #59
					cf.within("section_picker", (sp) => {
						sp.tap("option", { domain: "category", props: { category_section: "food" }, afterMs: 1300 }); // #62
					});
					cf.submit("done", { domain: "category", props: { category_section: "food", was_inserted: true, entry: "sheet" }, afterMs: 1700 }); // #60
				});
				cp.tap("row", { domain: "category", props: { category: "custom", category_section: "food" }, afterMs: 1200 }); // #57
			});
			f.submit("done", {
				domain: "transaction",
				props: { preset: false, transaction_type: "debit", category: "custom", amount_bucket: "10_25", is_valid: true, has_changes: true },
				afterMs: 3100,
			}); // #39
		});
		s.at("transactions").view("transaction_card", {
			domain: "transaction",
			props: { position: 0, transaction_type: "debit", category: "custom", amount_bucket: "10_25" },
			afterMs: 700,
		}); // #28
	},
);
