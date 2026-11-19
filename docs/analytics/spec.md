# Expensaro analytics spec: v3 (final draft)

Source: `/Users/mikhailkolkov/Desktop/Expensaro`, branch `master` @ `500ea54` plus the uncommitted working tree:

- Aptabase removed;
- `adminMode` moved to the `-adminMode` launch argument;
- the `transaction_type` default fix.

File:line references point to the **current working tree**. Paths are relative to `Expensaro/`.

## What changed

**v2:**

- `layer` is where the user is;
- every row has a `domain`;
- sheets, pickers, alerts and router covers are presentations owned by the screen that opens them, with the effect `presents(...)`;
- the `shell` owner was added;
- amounts are bucketed;
- `category` is an enum;
- `close` carries `has_changes`;
- there is one `goal_form`;
- Debug is not tracked;
- Aptabase was reduced to an appendix.

**v3:**

1. **Session context (§1b).** App-level constants are sent once in `session_init` and mutable app settings via `session_update`. Events carry only `session_id` + `seq`. No currency props remain on events. Amounts and buckets are currency-agnostic.
2. `settings` is its own layer (confirmed).
3. **New `account` domain** for erase, currency, notification permission and toggle, and profile creation. Rows were re-checked (§9).
4. Toolbar elements are named after what they open (accepted).
5. **Tab tap effect is `stays`.** The screen you land on logs its own `view`. No runtime-resolved effects remain.
6. Goal "+" is not declared (deferred to the Goals refactor). `goal_form{create}` stays listed with no entry point.
7. A custom category that reuses a base name maps to the base enum value (accepted, §7.6).
8. **`transaction_type`:** `unset` is removed. The add form now defaults to Debit: `AddTx:86-88` sets `type = Source.Strings.SegmentPickerType.transactionType.firstTab` when empty.
9. The notifications toggle is tracked as-is. Note that it doesn't affect local reminders.
10. **`Periodicity`** is semantic: `weekly` / `monthly` / `quarterly` / `yearly`. The mapping is in §7.6.
11. **Two-object actions:** domain is the record the user creates, plus a bool for the origin. A daily spend is `transaction` with `preset:true` (§7.4).
12. §8 Open questions is now empty.

### File keys

| Key | Path |
|---|---|
| App | `ExpensaroApp.swift` |
| Source | `Resources/Source.swift` |
| Accessory / AccMenu | `Navigation/Accessory/AccessoryContent.swift` / `TabAccessoryMenu.swift` |
| RootTabView / RootTabBar | `Modules/Tab Bar Module/*.swift` |
| Alerts | `Navigation/WithRouterAlerts.swift` |
| Pushes | `Navigation/WithAppRouter.swift` |
| Home, TxList, TxDetail, RpList, RpDetail | `Modules/Home Module/{Core/HomeView, Helpers/TransactionsListView, TransactionDetailView, RecurrentPaymentsListView, RecurrentPaymentDetailView}.swift` |
| TxInsights / DailyInsights | `Modules/Home Module/Helpers/Insights/{TransactionInsightsView,DailyTransactionInsightsView}.swift` |
| DailyList / DailyIntro | `Modules/Daily Transactions Module/{DailyTransactionsListView,DailyTransactionsOnboarding}.swift` |
| GoalsList / GoalDetail / EditGoal / Estimator / GoalPlan | `Modules/Goals Module/{Core/GoalsListView, Helpers/GoalDetailView, EditGoalView, GoalEstimatorView, GoalAnalyticsView}.swift` |
| Overview / TopCat / Recap / Breakdown | `Modules/Overview Module/{Core/OverviewView, Helpers/TopCategoryOverviewView, MonthRecapOverviewView, CategoriesBreakdownOverviewView}.swift` |
| Settings / AppSettings / Currency / Categories / AddCategory / Reminders / Erase / Contact | `Modules/Settings Module/{Core/SettingsView, Helpers/AppSettingsView, CurrencySelectorView, CategoriesSettingsView, AddCategoryView, RemindersSettingsView, EraseDataSettingsView, ContactSettingsView}.swift` |
| Onboarding / Permissions | `Modules/Onboarding Module/{Core/OnboardingView, Helpers/InitialPermissionView}.swift` |
| AddTx / AddRp / AddBudget / AddGoal / AddContrib / AddDaily | `Views/Adding Views/Core/{AddTransactionView, AddRecurrentPaymentView, AddBudgetView, AddGoalView, AddGoalTransactionView, AddDailyTransactionView}.swift` |
| CatPicker / DatePick / PeriodPick / RpCalendar | `Views/Adding Views/Helpers/{CategorySelectorView,DateSelectorView,PeriodicitySelectorView}.swift`, `Views/Helpers/EXDatePicker.swift` |

### Facts about the code that shape the spec

1. **Goal creation has no entry.** `RouterCover.addGoal` (`Navigation/RouterCover.swift:25`) is never presented. Deferred to the Goals refactor.
2. **No deep links and no notification-tap routing.** The only delegate method is `willPresent` (`Managers/LocalNotificationsManager.swift:85`).
3. **Edit forms write fields through live bindings** (`AddTx:45,55,60`, `AddRp:50,59,64,122,127`, `EditGoal:60`). So `close` with `has_changes:true` in edit mode means the changes were kept without a submit.
4. **The Home accessory is conditional.** It needs a budget with `amount != 0` and at least 1 transaction this month (`Accessory:115`).

---

## 1. Layers and owners

| Layer | Purpose | Entry | Root policy |
|---|---|---|---|
| `home` | Dashboard across the transaction, recurring_payment, daily_transaction and budget domains | Tab `RouterTab.home` (default, `Navigation/Router.swift:16`) | `tab` |
| `goals` | Goals and contributions | Tab `RouterTab.goals` | `tab` |
| `overview` | Top category this month, last-month recap | Tab `RouterTab.overview` | `tab` |
| `settings` | Categories, reminders, currency, reset, feedback, rate, feature voting. Own layer although pushed on the Home stack | Push from `home.dashboard.toolbar.settings` (`Home:66`) | `route` |
| `onboarding` | Feature pager, permissions and currency, profile creation | `ContentView` while `isUserLoggedIn == false` (`App:24-31`) | `session` |

**Owners**

- **`screen`**: the default owner.
- **`shell`**: owns `tab_bar` and `accessory`. Shell events carry the current `layer` and `screen` (the top of the selected tab's stack). Accessory options take the domain of the item they act on.

Debug (`Modules/Debug Module/DebugMenuView.swift`, behind `-adminMode`) is **not tracked**.

## 1b. Session context

App-level values are sent **once per session** and never repeated on events.

**Event envelope** (every event):

| Field | Type |
|---|---|
| `session_id` | string (UUID generated at launch) |
| `seq` | int (monotonic per session) |
| `timestamp` | timestamp |
| `owner` | screen / shell |
| `layer` | Layer |
| `screen` | Screen |
| `component` | Component |
| `element` | Element |
| `interaction` | view / tap / submit |
| `effect` | Effect |
| `domain` | Domain |
| `props` | declared props only |
| `host` | Host; only inside nested presentations (§7.3) |

### `session_init`

Emitted once at launch (`AppDelegate.didFinishLaunching`, `App:37`), before any other event.

| Field | Type | Source in code / platform |
|---|---|---|
| `session_id` | string | generated |
| `started_at` | timestamp | generated |
| `spec_version` | string | constant of the tracking layer (`"3.0"`) |
| `app_version` | string | `CFBundleShortVersionString` (already read in `Settings:154-159`) |
| `build` | string | `CFBundleVersion` |
| `platform` | enum `ios` | the only target |
| `os_version` | string | `UIDevice.current.systemVersion` |
| `device_class` | enum `phone` / `pad` | `UIDevice.current.userInterfaceIdiom` |
| `locale` | string | `Locale.current.identifier`. Currency names and symbols are localized from it (`Resources/Enums/Currency.swift:37-38`) |
| `time_zone` | string | `TimeZone.current.identifier`. Month boundaries use `Calendar.current` (`Resources/Extensions/Date+Extension.swift:12-14`) |
| `currency` | string (ISO 4217) | `@AppStorage("currencySign")`. Default `"USD"` in most views, `""` before onboarding sets it (`Permissions:19`) |
| `schema_version` | string | `CurrentSchema.versionIdentifier` (`Models/Storage/Schema.swift:17`) |
| `launch_root` | enum `onboarding` / `home` | `isUserLoggedIn` (`App:24-31`) |
| `notifications_enabled` | bool | `UserDefaults "notificationsEnabled"` |
| `reduce_motion` | bool | `accessibilityReduceMotion`, which changes accessory motion (`AccMenu:19,26-28`) |

### `session_update`

Emitted when an `account` action changes a mutable session field. Payload: `session_id`, `seq`, `field` (enum), `value` (string or bool).

| `field` | Changed by (spec rows, §9) |
|---|---|
| `currency` | #165 (settings currency), #189 (onboarding finish writes `currencySign`, `Permissions:76`) |
| `notifications_enabled` | #174, #187, and #189 (onboarding finish persists the toggle state), #180 (erase sets it false, `Erase:126`) |
| `launch_root` (as `onboarded`) | #189 (→ home), #180 (→ onboarding) |

**Amounts.** Every `*_bucket` prop is in currency units, with no currency assumption. The session's `currency` gives it meaning. Events carry no currency field.

---

## 2. Domains: objects and actions

8 domains: `transaction`, `recurring_payment`, `daily_transaction`, `goal`, `goal_transaction`, `budget`, `category`, `account`. `none` is for pure navigation and chrome. ⚠ = excluded under the no-free-text rule.

### 2.1 `transaction`

- **Props:** `transaction_type`, `category`, `category_section`, `amount_bucket`, `has_note`, `preset`.
- **Excluded:** ⚠ name, ⚠ note, ⚠ raw `categoryName`.

| Action | Implementation | Started from |
|---|---|---|
| create (spend) | `Transaction.spend(from:)` `Transaction+Record.swift:52` | `transaction_form{create}` on home.dashboard (accessory, empty CTA) and home.transactions (toolbar) |
| create from preset (daily spend, `preset:true`) | `DailyTransaction.spend(from:)` `DailyTransaction+Record.swift:27` → `Transaction.spend` | shell `accessory.daily_preset` on home.dashboard (`Accessory:117-124`). Silently no-op over budget |
| edit amount | `changeAmount(to:in:)` `:58` (other fields live-bound) | `transaction_form{edit}` from the home.transaction_detail accessory. Not offered for Refill (`Accessory:148`) |
| delete | `delete(restoring:)` `:66` | `transaction_deletion.primary` (`Alerts:49-52`) |
| note | live binding (`TxDetail:138`), autosaved | `note_sheet` on home.transaction_detail |

### 2.2 `recurring_payment`

- **Props:** `periodicity`, `reminder_type`, `has_reminder`, `transaction_type`, `category`, `amount_bucket`, `is_due`, `days_until_due`.
- **Excluded:** ⚠ name, ⚠ note.

| Action | Implementation | Started from |
|---|---|---|
| create (charges budget, schedules reminder) | `create(amount:charging:)` `RecurrentPayment+Record.swift:28` | `payment_form{create}` → `reminder_prompt.primary/secondary` (`AddRp:162-177`) |
| edit amount | `update(amount:in:)` `:36` | `payment_form{edit}` from the home.payment_detail accessory |
| toggle reminder | `setReminder(_:)` `:44` | `home.payment_detail.reminder.toggle` (`RpDetail:90-97`) |
| renew | `renew(from:)` `:52` (creates PaymentContributions, part of this domain) | `home.payment_detail.header.renew` (`RpDetail:47`) |
| delete (refunds if not due) | `delete(refunding:)` `:66` | `payment_deletion.primary` (`Alerts:54-59`) |
| disable all reminders (bulk, all payments) | `static disableAllReminders(in:)` `:75` | settings.reminders → `reminders_reset.primary` (`Reminders:146-148`) |
| note | live binding (`RpDetail:178`) | `note_sheet` on home.payment_detail |

### 2.3 `daily_transaction` (presets)

- **Props:** `amount_bucket`, `category`, `position`.

| Action | Implementation | Started from |
|---|---|---|
| create preset | `create(amount:)` `DailyTransaction+Record.swift:17` | `daily_transaction_form.done` (`AddDaily:52`) |
| delete preset | `ActiveRecord.delete()` (`Models/Storage/ActiveRecord.swift:34`) | `daily_transactions.preset_row` swipe (`DailyList:49-51`) |

### 2.4 `goal`

- **Props:** `goal_status`, `progress`, `days_left`, `amount_bucket` (target), `saved_bucket`, `contribution_count`.

| Action | Implementation | Started from |
|---|---|---|
| create | `create(finalAmount:)` `Goal+Record.swift:21` | `goal_form{create}`: **no entry point** (deferred) |
| edit amount/date | `save()` (`EditGoal:146-149`); date live-bound | `goal_form{edit}` from the goals.goal_detail accessory |
| delete (cascades contributions) | `ActiveRecord.delete()` via `Alerts:64` | `goal_deletion.primary` |

### 2.5 `goal_transaction`

| Action | Implementation | Started from |
|---|---|---|
| add funds | `Goal.contribute(_:)` `Goal+Record.swift:29` (updates `goal.currentAmount`) | `goal_form{add_funds}` (`AddContrib:40`) from the goals.goal_detail accessory |

### 2.6 `budget`

| Action | Implementation | Started from |
|---|---|---|
| create | `start(with:)` `Budget+Record.swift:23` | `budget_form{create}` → `budget_confirm.primary` (`AddBudget:67-72`) |
| add funds | `addFunds(_:)` `:31`. Also inserts a Refill transaction as its receipt (§7.4) | `budget_form{add_funds}.done` (`AddBudget:45-50`) |

### 2.7 `category`

- **Props:** `category`, `category_section`, `category_tag`.
- **Excluded:** ⚠ custom name, emoji.

| Action | Implementation | Started from |
|---|---|---|
| create custom | `addIfMissing(into:)` `Category+Record.swift:24` (no-op if the name exists) | settings.category_form (push); `category_form` presentation from `category_picker` |
| delete (base or custom) | `ActiveRecord.delete()` | `settings.categories.list.category_row` swipe (`Categories:35`) |
| select into a form | binding (`CatPicker:37-42`) | `category_picker.row` |

### 2.8 `account` (app-level, no specific object)

| Action | Implementation | Started from |
|---|---|---|
| create profile (finish onboarding) | `isUserLoggedIn = true`, seeds base categories, writes currency (`Permissions:73-83`, `Models/Storage/DemoSeeder.swift:16`) | `onboarding.intro.permissions.finish` |
| change currency | `@AppStorage("currencySign")` | `settings.currency.list.currency_cell` (`Currency:28-30`); onboarding `currency_picker` (local until finish) |
| notification permission | `NotificationManager.requestAuthorization` (`Managers/LocalNotificationsManager.swift:23`) | `permissions` appear (`Permissions:93-105`) |
| toggle push notifications (doesn't gate local reminders) | `UserDefaults notificationsEnabled` + (un)register (`Reminders:34-50`, `Permissions:45-59`) | settings.reminders, onboarding permissions |
| erase all data and log out | `AppModelStore.eraseAllData()` (`Models/Storage/Schema.swift:100`), `router.reset()`, `isUserLoggedIn=false` (`Erase:120-132`). Doesn't reset `currencySign` | `settings.reset.reset_confirm.primary` |

**Counts: 8 domains + `none`, 25 user actions.**

---

## 3. Screens and presentations

### 3.1 Screens

| Layer | Screen | Route case | Input | Source | Root policy |
|---|---|---|---|---|---|
| home | `dashboard` | tab root (`HomeRootView`) | none | Home | tab |
| home | `transactions` | `RouterDestination.transactionsList` | none | TxList | route |
| home | `transaction_detail` | `.transactionDetail(Transaction, Budget)` | transaction, budget | TxDetail | route |
| home | `payments` | `.recurringPaymentsList(Budget)` | budget | RpList | route |
| home | `payment_detail` | `.recurringPaymentDetail(RecurringTransaction, Budget)` | payment, budget | RpDetail | route |
| goals | `list` | tab root (`GoalsRootView`) | none | GoalsList | tab |
| goals | `goal_detail` | `.goalDetail(Goal)` | goal | GoalDetail | route |
| overview | `dashboard` | tab root (`OverviewRootView`) | none | Overview | tab |
| overview | `top_category` | `.topCategoryOverview(TopCategorySummary)` | snapshot (`isLocked` = demo) | TopCat | route |
| overview | `month_recap` | `.monthRecap(MonthRecap)` | snapshot (`isLocked` = demo) | Recap | route |
| settings | `root` | `.settings` | none | Settings | route |
| settings | `app` | `.appSettings` | none | AppSettings | route |
| settings | `currency` | `.currencySelector` | none | Currency | route |
| settings | `categories` | `.categoriesSettings` | none | Categories | route |
| settings | `category_form` | `.addCategory` | draft Category | AddCategory (`isSheet: false`) | route |
| settings | `reminders` | `.remindersSettings` | none | Reminders | route |
| settings | `reset` | `.eraseData` | none | Erase | route |
| settings | `feedback` | `.contact` | topic "General" (`Pushes:72`) | Contact (`isCalled: false`) | route |
| onboarding | `intro` | none, `ContentView` root | none | Onboarding | session |

**19 screens** (home 5, goals 2, overview 3, settings 8, onboarding 1). `.debugMenu` is excluded.

### 3.2 Presentations (components of the owning screen)

| Presentation | Kind | Router / local | Modes / input | Owning screens | Source |
|---|---|---|---|---|---|
| `budget_form` | cover | `RouterCover.addBudget` / `.updateBudget` | `create` / `add_funds` | home.dashboard | AddBudget |
| `budget_confirm` | popup (in budget_form) | local `AddBudget:63` | — | home.dashboard | AddBudget |
| `transaction_form` | cover | `.addTransaction` / `.editTransaction` | `create` / `edit` | home.dashboard, home.transactions, home.transaction_detail | AddTx |
| `payment_form` | cover | `.addRecurringPayment` / `.editRecurringPayment` | `create` / `edit` | home.dashboard, home.payments, home.payment_detail | AddRp |
| `reminder_prompt` | popup (in payment_form) | local `AddRp:139` | — | payment_form hosts | AddRp |
| `periodicity_picker` | sheet (in payment_form) | local `AddRp:121` | — | payment_form hosts | PeriodPick |
| `date_picker` | sheet (in payment_form, goal_form) | local `AddRp:126`, `AddGoal:79`, `EditGoal:59` | `picker_type` | payment_form hosts, goals.goal_detail | DatePick |
| `category_picker` | sheet (in transaction_form, payment_form, daily_transaction_form) | local `AddTx:101`, `AddRp:132`, `AddDaily:70` | — | those forms' hosts | CatPicker |
| `category_form` | sheet (in category_picker) | local `CatPicker:63-66` | draft Category | category_picker hosts | AddCategory (`isSheet: true`) |
| `section_picker` | sheet (in category_form, both entries) | local `AddCategory:53` | — | as above + settings.category_form | AddCategory |
| `daily_transactions` | cover | `RouterCover.dailyTransactions` | — | home.dashboard (via shell accessory) | DailyList |
| `daily_transaction_form` | cover (nested) | local `DailyList:57` | — | home.dashboard | AddDaily |
| `daily_intro` | sheet (nested) | local `DailyList:60` | — | home.dashboard | DailyIntro |
| `note_sheet` | sheet | local `TxDetail:89`, `RpDetail:110` | — | home.transaction_detail, home.payment_detail | TxDetail / RpDetail |
| `insights_info` | popup | local `TxInsights:93`, `DailyInsights:74` | `kind` | home.transaction_detail | TxInsights / DailyInsights |
| `transaction_deletion` | alert | `RouterAlert.deleteTransaction` | — | home.transaction_detail | Alerts |
| `payment_deletion` | alert | `RouterAlert.deleteRecurringPayment` | — | home.payment_detail | Alerts |
| `goal_form` | cover | `.addGoal` (no entry) / `.editGoal` / `.addGoalMoney` | `create` / `edit` / `add_funds` | goals.goal_detail | AddGoal / EditGoal / AddContrib |
| `goal_deletion` | alert | `RouterAlert.deleteGoal` | — | goals.goal_detail | Alerts |
| `top_category_info` | popup | local `Overview:42` | — | overview.dashboard | Overview |
| `month_recap_info` | popup | local `Overview:71` | — | overview.dashboard | Overview |
| `category_breakdown` | sheet | local `Recap:38` | — | overview.month_recap | Breakdown |
| `feedback` | cover | `RouterCover.feedback(topic:)` | `topic` | home.transaction_detail, overview.top_category, overview.month_recap | Contact (`isCalled: true`) |
| `features_hub` | sheet | `RouterSheet.featuresHub` | — (WishKit internals untracked) | settings.root | `Settings:162-175` |
| `reminders_reset` | sheet | local `Reminders:73` | — | settings.reminders | Reminders |
| `reset_confirm` | sheet | local `Erase:39` | — | settings.reset | Erase |
| `permissions` | sheet | local `Onboarding:60` | — | onboarding.intro | Permissions |
| `currency_picker` | sheet (in permissions) | local `Permissions:66` | — | onboarding.intro | Permissions |

**28 presentations**: 10 router-backed and 18 local.

---

## 4. Component map, per screen

Flag key:

- **[COND]**: shown only under the stated condition.
- **[NOOP]**: visible but triggers nothing.
- **[LOCAL]**: local UI state only, not tracked.

| Layer.screen | Components | Presentations owned | Flags |
|---|---|---|---|
| shell | `tab_bar`, `accessory` | presents the router covers listed per screen | Accessory hidden on goals.list, overview.dashboard and every push except the 3 detail screens (`Accessory:87-88,101-104`) |
| home.dashboard | `toolbar`, `budget`, `payments`, `transactions` | budget_form, budget_confirm, transaction_form, payment_form, reminder_prompt, periodicity_picker, date_picker, category_picker, category_form, section_picker, daily_transactions, daily_transaction_form, daily_intro | "+N more" counters [NOOP] (`Home:176-186,236-246`); zero-budget toast never shown (`Home:22,54`); empty CTAs disabled when `budget.amount == 0` (`Home:195,262`) |
| home.transactions | `nav`, `toolbar`, `summary`, `list` | transaction_form (+ nested) | — |
| home.transaction_detail | `nav`, `header`, `note`, `insights` | note_sheet, insights_info, feedback, transaction_form{edit}, transaction_deletion | category insights for Debit/Credit, daily insights for "Daily transaction", none for Refill (`TxDetail:80-85`) |
| home.payments | `nav`, `toolbar`, `calendar`, `list` | payment_form (+ nested) | `headerView` never rendered (`RpList:152`) |
| home.payment_detail | `nav`, `header`, `note`, `reminder` | note_sheet, payment_form{edit}, payment_deletion | renew only when `isDue` (`RpDetail:46`) |
| goals.list | `summary`, `list` | — | empty-state copy mentions a "+" that doesn't exist yet (`Resources/Enums/EXEmptyStates.swift:63`) |
| goals.goal_detail | `nav`, `progress`, `plan`, `contributions` | goal_form{edit, add_funds}, date_picker, goal_deletion | `plan` only when active |
| overview.dashboard | `top_category`, `month_recap`, `updates` | top_category_info, month_recap_info | `updates` [NOOP] |
| overview.top_category | `nav`, `toolbar`, `summary`, `other_categories` | feedback | — |
| overview.month_recap | `nav`, `toolbar`, `budget`, `categories`, `goals` | category_breakdown, feedback | learn_more hidden when empty (`Recap:167-168`) |
| settings.root | `nav`, `menu` | features_hub | "Export Data" case has no cell [NOOP] (`Settings:132`) |
| settings.app | `nav`, `menu` | — | — |
| settings.currency | `nav`, `list` | — | search state with no UI [NOOP] (`Currency:15-23`) |
| settings.categories | `nav`, `toolbar`, `list` | — | — |
| settings.category_form | `nav`, `details`, `toolbar` | section_picker | — |
| settings.reminders | `nav`, `general`, `reminders` | reminders_reset | the notifications toggle doesn't gate local reminders |
| settings.reset | `nav`, `danger` | reset_confirm | — |
| settings.feedback | `nav`, `form`, `toolbar` | — | — |
| onboarding.intro | `pager`, `footer` | permissions, currency_picker | permissions can't be swipe-dismissed (`Permissions:71`) |

[LOCAL] controls excluded everywhere:

- amount backspace and keypad digits (`Resources/ViewModifiers/EXNumberKeyboard.swift:86`);
- text fields;
- drag-to-dismiss.

---

## 5. Edges

### 5.1 `navigates` (pushes, pops, session switches)

Tab taps are not edges: their effect is `stays`, and the screen you land on logs its own `view`.

| From | To | Route case |
|---|---|---|
| home.dashboard `toolbar.settings` | settings.root | `.settings` |
| home.dashboard `payments.all` / `payments.payment_card` | home.payments / home.payment_detail | `.recurringPaymentsList` / `.recurringPaymentDetail` |
| home.dashboard `transactions.all` / `transactions.transaction_card` | home.transactions / home.transaction_detail | `.transactionsList` / `.transactionDetail` |
| home.transactions `list.transaction_row` | home.transaction_detail | `.transactionDetail` |
| home.payments `list.payment_row` | home.payment_detail | `.recurringPaymentDetail` |
| goals.list `list.goal_card` | goals.goal_detail | `.goalDetail` |
| overview.dashboard `top_category.card`, `top_category_info.primary` | overview.top_category | `.topCategoryOverview` |
| overview.dashboard `month_recap.card`, `month_recap_info.primary` | overview.month_recap | `.monthRecap` |
| settings.root `menu.categories` / `reminders` / `general` / `reset` / `contact` | settings.categories / reminders / app / reset / feedback | `.categoriesSettings` / `.remindersSettings` / `.appSettings` / `.eraseData` / `.contact` |
| settings.app `menu.currency` | settings.currency | `.currencySelector` |
| settings.categories `toolbar.category_form` | settings.category_form | `.addCategory` |
| settings.reset `reset_confirm.primary` | onboarding.intro | `router.reset()` + `isUserLoggedIn=false` |
| onboarding.intro `permissions.finish` | home.dashboard | `isUserLoggedIn=true` |
| any push `nav.back`; `*_deletion.primary`; settings.category_form `toolbar.done`; settings.feedback `toolbar.send` | previous (pop) | `router.back()` / `back(thenPerform:)` |

**21 forward `navigates` edges**, plus pops. Each pair in a row counts separately, and the settings.root menu row counts as 5.

### 5.2 `presents`

| From (screen · component.element) | Presents |
|---|---|
| home.dashboard · `budget.budget_form` / `budget.empty_cta` | budget_form{add_funds} / {create} |
| home.dashboard · `budget_form.done` (create) | budget_confirm |
| home.dashboard · `payments.empty_cta`; shell `accessory.payment_form` | payment_form{create} |
| home.dashboard · `transactions.empty_cta`; shell `accessory.transaction_form` | transaction_form{create} |
| home.dashboard · shell `accessory.daily_transactions` | daily_transactions |
| home.dashboard · `daily_transactions.daily_transaction_form` / `.help` | daily_transaction_form / daily_intro |
| home.transactions · `toolbar.transaction_form` | transaction_form{create} |
| home.transaction_detail · shell `accessory.transaction_form` / `.transaction_deletion` | transaction_form{edit} / transaction_deletion |
| home.transaction_detail · `note.card` | note_sheet |
| home.transaction_detail · `insights.category_card` / `insights.daily_card` (locked) | insights_info{transaction} / {daily} |
| home.transaction_detail · `insights.feedback` / `insights.daily_feedback` | feedback{transaction_insights} / {daily_transaction_insights} |
| home.payments · `toolbar.payment_form` | payment_form{create} |
| home.payment_detail · shell `accessory.payment_form` / `.payment_deletion` | payment_form{edit} / payment_deletion |
| home.payment_detail · `note.card` | note_sheet |
| {hosts} · `transaction_form.category` / `payment_form.category` / `daily_transaction_form.category` | category_picker |
| {hosts} · `category_picker.category_form` | category_form |
| {hosts} · `category_form.section`; settings.category_form · `details.section` | section_picker |
| {hosts} · `payment_form.periodicity` / `.due_date` | periodicity_picker / date_picker |
| {hosts} · `payment_form.done` (create) | reminder_prompt |
| goals.goal_detail · shell `accessory.goal_form_add_funds` / `.goal_form_edit` / `.goal_deletion` | goal_form{add_funds} / {edit} / goal_deletion |
| goals.goal_detail · `goal_form.due_date` | date_picker |
| (none, deferred) | goal_form{create} |
| overview.dashboard · `top_category.locked_card` / `month_recap.locked_card` | top_category_info / month_recap_info |
| overview.top_category · `toolbar.feedback` | feedback{top_category} |
| overview.month_recap · `toolbar.feedback` / `categories.learn_more` | feedback{month_recap} / category_breakdown |
| settings.root · `menu.features_hub` | features_hub |
| settings.reminders · `reminders.reset_button` | reminders_reset |
| settings.reset · `danger.reset_button` | reset_confirm |
| onboarding.intro · `footer.start` / `permissions.currency` | permissions / currency_picker |

**39 `presents` edges**, plus 1 with no entry point (`goal_form{create}`).

### 5.3 Without a tap

| Trigger | Result | Where |
|---|---|---|
| Launch | `session_init`, then onboarding.intro or home.dashboard | `App:26-30`, `Navigation/Router.swift:16` |
| Onboarding finish (2 s delay) | home.dashboard + `session_update` | `Permissions:77-82` |
| Reset confirm | `router.reset()` → onboarding.intro + `session_update` | `Erase:128-130`, `Navigation/Router.swift:154-163` |
| First open of daily_transactions | presents daily_intro (`is_auto=true`) | `DailyList:64-68` |
| permissions appear | system notification prompt | `Permissions:93-105` |
| budget_confirm.primary | form auto-closes after 1 s | `AddBudget:69-72` |
| deletion confirm | detail popped programmatically | `Alerts:50,55,61` |
| feedback toast hide | pop or close | `Contact:55-60` |
| Notification tap / deep link | none exist | Fact 2 |

---

## 6. Appendix: replaced Aptabase events

Aptabase has been removed from the app. The lesson carried into the spec is **no free text in props** (§7.4).

| Old event | New path · interaction |
|---|---|
| createdBudget | home.dashboard.budget_confirm.primary · tap |
| updatedBudget | home.dashboard.budget_form.done · submit {mode=add_funds} |
| createdReminder / deniedReminder | {host}.reminder_prompt.primary / .secondary · tap |
| modifiedReminder | home.payment_detail.reminder.toggle · tap |
| createPayment | {host}.reminder_prompt.primary / .secondary · tap |
| editPayment | {host}.payment_form.done · submit {mode=edit} |
| deletePayment | home.payment_detail.payment_deletion.primary · tap |
| paymentRenewed | home.payment_detail.header.renew · tap |
| createTransaction / editTransaction | {host}.transaction_form.done · submit {mode} |
| deleteTransaction | home.transaction_detail.transaction_deletion.primary · tap |
| madeNote | {host}.note_sheet.done · submit |
| openedSelectedAnalyticsPreview | home.transaction_detail.insights.category_card · tap (locked) |
| createGoal / editGoal | goals.goal_detail.goal_form.done · submit {mode} |
| addMoneyToGoal | goals.goal_detail.goal_form.done · submit {mode=add_funds} |
| deleteGoal | goals.goal_detail.goal_deletion.primary · tap |
| openTopCategory / openMonthRecap | overview.dashboard.top_category.card / month_recap.card · tap |
| openTopCategoryPreview / openMonthRecapPreview | overview.dashboard.top_category_info.primary / month_recap_info.primary · tap |
| openCategoryBreakdown | overview.month_recap.categories.learn_more · tap |
| createCategory | settings.category_form.toolbar.done or {host}.category_form.done · submit |
| removeReminders | settings.reminders.reminders_reset.primary · tap |
| deleteAccount | settings.reset.reset_confirm.primary · tap |
| sendFeedback | settings.feedback.toolbar.send or {host}.feedback.send · submit |
| profileCreated | onboarding.intro.permissions.finish · submit |
| dailyTransactionCreated | home.dashboard.daily_transaction_form.done · submit |
| dailyTransactionUsed | shell accessory.daily_preset · tap {preset:true} |
| dailyTransactionDeleted | home.dashboard.daily_transactions.preset_row · submit |

---

## 7. Naming and vocabulary

### 7.1 Ids

1. Path: `layer.screen.component.element`, all `snake_case`. Presentations are components and their controls are elements. Screen ids don't repeat the layer.
2. **No verbs in ids.** A control is named for what it opens (`toolbar.transaction_form`, `accessory.payment_form`). If one screen offers the same presentation in two modes, append the mode (`goal_form_edit`, `goal_form_add_funds`).
3. **Reserved element ids:**
   - `back` (component `nav`);
   - `close`;
   - `done` (submit);
   - `primary` / `secondary` (alert and prompt buttons, per `EXAlert`);
   - `error` (validation toast);
   - `empty_cta` / `empty_state`;
   - `menu`;
   - `tab`.
4. **Forms:** one id per object with a `mode` prop:
   - `transaction_form`: `create` / `edit`;
   - `payment_form`: `create` / `edit`;
   - `budget_form`: `create` / `add_funds`;
   - `goal_form`: `create` / `edit` / `add_funds`;
   - `daily_transaction_form` and `category_form`: create only.

   `close` always carries `has_changes: bool`. It means "kept without submit" in edit mode and "non-empty draft discarded" in create mode. It is never a cancel.
5. Ids may shorten domain names (`payments`, `payment_form`). The `domain` field uses the full value (`recurring_payment`).

### 7.2 Effects

| Effect | Meaning |
|---|---|
| `stays` | The screen's context doesn't change: local selection, closing a presentation, an in-place data write, **and every tab tap** (the landing screen logs `view`) |
| `reroots` | Changes the screen's context in place: the payments calendar day or month (`RpCalendar:30,40,73`) |
| `navigates(screen)` | Push, pop (`navigates(previous)`) or session switch. Always statically declared |
| `presents(presentation[, mode])` | Opens a cover, sheet, popup or alert owned by the current screen |

A submit that writes data and closes its presentation has the effect `stays`. The write is the domain action.

### 7.3 Context fields

- The envelope is defined in §1b; session constants are never on events.
- `host` (enum) is set only for nested presentations: `transaction_form`, `payment_form`, `daily_transaction_form`, `goal_form`, `category_picker`, `category_form`, `permissions`, `daily_transactions`.
- Screen and presentation `view`s are implied by their declarations.

### 7.4 Prop rules

- **No free text, ever.** That covers names, notes, email, feedback message, emoji and custom category names. Booleans and lengths derived from them are allowed.
- No model ids, no currency, no session constants.
- Positions are `int` (0-based). Booleans start with `is_` / `has_` (exceptions: `preset`, `succeeded`). Money is always `*_bucket: AmountBucket`.
- **Two-object actions:** `domain` is the record the user creates or changes on purpose. The other record is expressed by a bool:
  - **Daily spend:** `domain=transaction`, `preset:true` (#6). A normal transaction submit has `preset:false` (#39).
  - **Budget add funds:** the Refill transaction it inserts is a receipt, not a user intent, so the action stays `budget`. Its later display or deletion is `transaction` with `transaction_type=refill`.
  - **Goal contribution:** `goal_transaction`; the goal's saved total updates implicitly.
  - **Renewal:** creates PaymentContributions, which are part of `recurring_payment`.
  - **Budget balance:** changes are implicit side effects of all money actions and never a second domain.

### 7.5 `AmountBucket` (currency-agnostic units; lower bound inclusive)

| Value | Range |
|---|---|
| `negative` | < 0 (balance after deleting a Refill: `Transaction+Record.swift:67`) |
| `zero` | = 0 (balances only; forms reject 0) |
| `under_10` | (0, 10) |
| `10_25` | [10, 25) |
| `25_50` | [25, 50) |
| `50_100` | [50, 100) |
| `100_250` | [100, 250) |
| `250_500` | [250, 500) |
| `500_1k` | [500, 1 000) |
| `1k_2_5k` | [1 000, 2 500) |
| `2_5k_5k` | [2 500, 5 000) |
| `5k_10k` | [5 000, 10 000) |
| `10k_plus` | ≥ 10 000 |

**Why these edges:**

- **Even resolution at every scale.** A 1–2.5–5 series is roughly log-uniform, so small and large amounts get the same relative precision.
- **They fit the app's own reference values.** The daily-preset copy cites 2.90 (`DailyIntro:30`). Sample transactions and payments range from 7.88 to 150, and budgets and goals from 800 to 3 200 (`Source.DefaultData`, `Source:730+`).
- **Headroom and real states.** The two top buckets cover large budgets; `negative` and `zero` are real states of `budget_left_bucket`.
- **No currency assumption.** The session's `currency` gives the units meaning.

**Bucket props:** `amount_bucket`, `budget_left_bucket`, `spent_bucket`, `saved_bucket`, `remaining_bucket`, `total_saved_bucket`, `unused_bucket`, `contribution_bucket`.

### 7.6 Enums

| Enum | Values | Source / mapping |
|---|---|---|
| `Domain` | `transaction`, `recurring_payment`, `daily_transaction`, `goal`, `goal_transaction`, `budget`, `category`, `account`, `none` | §2 |
| `Category` | `subscription`, `entertainment`, `hobby`, `going_out`, `groceries`, `bills`, `utilities`, `public_transport`, `car`, `education`, `travel`, `shopping`, `delivery`, `gaming`, `animals`, `clothes`, `other`, `healthcare`, `added_funds`, `custom` | 18 base names (`Source:777-799`, snake-cased) plus `added_funds` (Refill pseudo-category, `Transaction+Record.swift:12`). Every other name maps to `custom`. Mapping is **by name**, because transactions store only `categoryName`. A custom category that reuses a base name (possible after the base one is deleted) maps to the base value (accepted) |
| `CategorySection` | `food`, `housing`, `transportation`, `entertainment`, `lifestyle`, `other` | `Category.swift:43-49` |
| `CategoryTag` | `base`, `custom` | `Category.swift:37-39` |
| `TransactionType` | `debit`, `credit`, `refill`, `daily` | "Debit" / "Credit" (`Source:172,179`), "Refill" (`Transaction+Record.swift:48`), "Daily transaction" (`:13`). The new-transaction default is now Debit (`AddTx:86-88`), so there's no `unset`. Recurring payments use the same segment control |
| `Periodicity` | `weekly`, `monthly`, `quarterly`, `yearly` | see the mapping table below |
| `ReminderType` | `day`, `week` | `RecurrentPayment.swift:74-76` |
| `GoalStatus` | `active`, `completed`, `failed` | `Goal.swift:57-63` |
| `SuccessRate` | `no_risk`, `moderate_risk`, `high_risk`, `no_data` | `Goal.swift:114-118` |
| `TimeUnit` | `week`, `month` | `GoalPlan:69-71` |
| `FormMode` | `create`, `edit`, `add_funds` | router cases, `AddBudgetView.ScreenType` |
| `FeedbackTopic` | `general`, `transaction_insights`, `daily_transaction_insights`, `top_category`, `month_recap` | "General" (`Pushes:72`), "Transaction Insights" (`TxInsights:56`), "Daily Transactions Insights" (`DailyInsights:44`), "Top Category Overview" (`TopCat:120`), "Month Recap" (`Recap:57`) |
| `FeedbackEntry` / `CategoryFormEntry` | `push`, `cover` / `push`, `sheet` | `isCalled` / `isSheet` |
| `ErrorReason` | `empty_name`, `zero_amount`, `budget_exceed`, `past_date` | `EXToasts` (`Source:479-488`) |
| `Tab` | `home`, `goals`, `overview` | `RouterTab` |
| `AccessoryStyle` | `add`, `item` | `AccessoryContent.Style` |
| `InsightKind` | `transaction`, `daily` | — |
| `PickerType` | `set_goal_date`, `set_recurrent_date`, `update_goal_date` | `DateSelectorView.SelectorType` |
| `Feature` | `custom_categories`, `smart_goals_payment_suggestions`, `goal_success_rate`, `selected_category_breakdown`, `payment_alerts`, `top_category_analytics`, `previous_month_recap`, `recap_categories_breakdown` | `AppFeatures` |
| `Host` | §7.3 | — |
| Session enums | `platform`: `ios`; `device_class`: `phone` / `pad`; `launch_root`: `onboarding` / `home`; `session_update.field`: `currency` / `notifications_enabled` / `launch_root` | §1b |

**Periodicity mapping** (raw `RecurringSchedule`, `RecurrentPayment.swift:54-58`; day offsets from `nextDueDate`, `RecurrentPayment+Record.swift:16-24`):

| Raw value | UI title | Next due offset | Spec value |
|---|---|---|---|
| `everyWeek` | Every week | +7 days | `weekly` |
| `everyMonth` | Every month | +31 days | `monthly` |
| `every3Month` | Every 3 months | +90 days | `quarterly` |
| `everyYear` | Every year | +365 days | `yearly` |

---

## 8. Open questions

None. Every v2 question was resolved, with decisions recorded in "What changed" (v3).

---

## 9. Spec table

How to read the rows:

- **Shell rows:** `layer.screen` is where the control appears; owner = shell.
- **`{…}` rows:** the element exists on every screen that owns that presentation (§3.2).
- **Types:** `B` = `AmountBucket`; other types are in §7.6.
- **Envelope:** the session envelope (§1b) applies to every row.

| # | layer | screen | component | element | interaction | effect | domain | props | file:line |
|---|---|---|---|---|---|---|---|---|---|
| 1 | * (shell) | * | tab_bar | tab | tap | stays | none | tab:Tab, is_reselect:bool, stack_depth:int | RootTabBar:50,82-88 |
| 2 | * (shell) | * | accessory | menu | view | stays | none | style:AccessoryStyle, option_count:int | AccMenu:30-57 |
| 3 | * (shell) | * | accessory | menu | tap | stays | none | style:AccessoryStyle, is_expanded:bool | AccMenu:81 |
| 4 | * (shell) | * | accessory | scrim | tap | stays | none | — | RootTabView:106 |
| 5 | home (shell) | dashboard | accessory | daily_preset | view | stays | daily_transaction | position:int, amount_bucket:B, category:Category | Accessory:117 |
| 6 | home (shell) | dashboard | accessory | daily_preset | tap | stays | transaction | preset:bool(true), position:int, amount_bucket:B, category:Category, succeeded:bool | Accessory:117-124 |
| 7 | home (shell) | dashboard | accessory | daily_transactions | tap | presents(daily_transactions) | daily_transaction | preset_count:int | Accessory:126-130 |
| 8 | home (shell) | dashboard | accessory | transaction_form | tap | presents(transaction_form, create) | transaction | — | Accessory:135 |
| 9 | home (shell) | dashboard | accessory | payment_form | tap | presents(payment_form, create) | recurring_payment | — | Accessory:138 |
| 10 | home (shell) | transaction_detail | accessory | transaction_form | tap | presents(transaction_form, edit) | transaction | transaction_type:TransactionType | Accessory:148-151 |
| 11 | home (shell) | transaction_detail | accessory | transaction_deletion | tap | presents(transaction_deletion) | transaction | transaction_type:TransactionType | Accessory:153 |
| 12 | home (shell) | payment_detail | accessory | payment_form | tap | presents(payment_form, edit) | recurring_payment | periodicity:Periodicity | Accessory:163 |
| 13 | home (shell) | payment_detail | accessory | payment_deletion | tap | presents(payment_deletion) | recurring_payment | is_due:bool | Accessory:166 |
| 14 | goals (shell) | goal_detail | accessory | goal_form_add_funds | tap | presents(goal_form, add_funds) | goal_transaction | goal_status:GoalStatus | Accessory:181 |
| 15 | goals (shell) | goal_detail | accessory | goal_form_edit | tap | presents(goal_form, edit) | goal | goal_status:GoalStatus | Accessory:184 |
| 16 | goals (shell) | goal_detail | accessory | goal_deletion | tap | presents(goal_deletion) | goal | goal_status:GoalStatus | Accessory:175 |
| 17 | home | dashboard | toolbar | settings | tap | navigates(settings.root) | none | — | Home:66 |
| 18 | home | dashboard | budget | balance | view | stays | budget | budget_left_bucket:B | Home:105-112 |
| 19 | home | dashboard | budget | budget_form | tap | presents(budget_form, add_funds) | budget | budget_left_bucket:B | Home:114 |
| 20 | home | dashboard | budget | empty_cta | view | stays | budget | — | Home:129 |
| 21 | home | dashboard | budget | empty_cta | tap | presents(budget_form, create) | budget | — | Home:135 |
| 22 | home | dashboard | payments | all | tap | navigates(home.payments) | recurring_payment | payment_count:int | Home:149 |
| 23 | home | dashboard | payments | payment_card | view | stays | recurring_payment | position:int, periodicity:Periodicity, is_due:bool, days_until_due:int, has_reminder:bool, amount_bucket:B, category:Category | Home:162 |
| 24 | home | dashboard | payments | payment_card | tap | navigates(home.payment_detail) | recurring_payment | (as 23) | Home:163 |
| 25 | home | dashboard | payments | empty_cta | view | stays | recurring_payment | is_enabled:bool | Home:192 |
| 26 | home | dashboard | payments | empty_cta | tap | presents(payment_form, create) | recurring_payment | — | Home:197 |
| 27 | home | dashboard | transactions | all | tap | navigates(home.transactions) | transaction | transaction_count:int | Home:216 |
| 28 | home | dashboard | transactions | transaction_card | view | stays | transaction | position:int, transaction_type:TransactionType, category:Category, amount_bucket:B | Home:227 |
| 29 | home | dashboard | transactions | transaction_card | tap | navigates(home.transaction_detail) | transaction | (as 28) | Home:228 |
| 30 | home | dashboard | transactions | empty_cta | view | stays | transaction | is_enabled:bool | Home:258 |
| 31 | home | dashboard | transactions | empty_cta | tap | presents(transaction_form, create) | transaction | — | Home:263 |
| 32 | home | dashboard | budget_form | done | submit | create: presents(budget_confirm); add_funds: stays | budget | mode:FormMode, amount_bucket:B, is_valid:bool | AddBudget:45-52 |
| 33 | home | dashboard | budget_form | close | tap | stays | budget | mode:FormMode, has_changes:bool | AddBudget:95 |
| 34 | home | dashboard | budget_form | error | view | stays | budget | mode:FormMode, reason:ErrorReason | AddBudget:54 |
| 35 | home | dashboard | budget_confirm | primary | tap | stays | budget | amount_bucket:B | AddBudget:67-72 |
| 36 | home | dashboard | budget_confirm | secondary | tap | stays | budget | — | AddBudget:73 |
| 37 | home | {dashboard, transactions, transaction_detail} | transaction_form | type | tap | stays | transaction | mode:FormMode, transaction_type:TransactionType | AddTx:45 |
| 38 | home | {…} | transaction_form | category | tap | presents(category_picker) | category | mode:FormMode | AddTx:57 |
| 39 | home | {…} | transaction_form | done | submit | stays | transaction | mode:FormMode, preset:bool(false), transaction_type:TransactionType, category:Category, amount_bucket:B, is_valid:bool, has_changes:bool | AddTx:67-74 |
| 40 | home | {…} | transaction_form | close | tap | stays | transaction | mode:FormMode, has_changes:bool | AddTx:115 |
| 41 | home | {…} | transaction_form | error | view | stays | transaction | mode:FormMode, reason:ErrorReason | AddTx:92 |
| 42 | home | {dashboard, payments, payment_detail} | payment_form | type | tap | stays | recurring_payment | mode:FormMode, transaction_type:TransactionType | AddRp:50 |
| 43 | home | {…} | payment_form | category | tap | presents(category_picker) | category | mode:FormMode | AddRp:61 |
| 44 | home | {…} | payment_form | periodicity | tap | presents(periodicity_picker) | recurring_payment | mode:FormMode, periodicity:Periodicity | AddRp:74 |
| 45 | home | {…} | payment_form | due_date | tap | presents(date_picker) | recurring_payment | mode:FormMode | AddRp:81 |
| 46 | home | {…} | payment_form | done | submit | create: presents(reminder_prompt); edit: stays | recurring_payment | mode:FormMode, periodicity:Periodicity, category:Category, amount_bucket:B, is_valid:bool, has_changes:bool | AddRp:88-95 |
| 47 | home | {…} | payment_form | close | tap | stays | recurring_payment | mode:FormMode, has_changes:bool | AddRp:196 |
| 48 | home | {…} | payment_form | error | view | stays | recurring_payment | mode:FormMode, reason:ErrorReason | AddRp:112 |
| 49 | home | {…} | reminder_prompt | reminder_type | tap | stays | recurring_payment | reminder_type:ReminderType | AddRp:147,154 |
| 50 | home | {…} | reminder_prompt | primary | tap | stays | recurring_payment | reminder_type:ReminderType, periodicity:Periodicity, amount_bucket:B | AddRp:162-169 |
| 51 | home | {…} | reminder_prompt | secondary | tap | stays | recurring_payment | periodicity:Periodicity, amount_bucket:B | AddRp:170-177 |
| 52 | home | {…} | periodicity_picker | option | tap | stays | recurring_payment | periodicity:Periodicity | PeriodPick:34 |
| 53 | home | {…} | periodicity_picker | close | tap | stays | none | — | PeriodPick:22 |
| 54 | home, goals | {payment_form hosts, goal_detail} | date_picker | date | tap | stays | recurring_payment / goal (by host) | host:Host, picker_type:PickerType, days_from_today:int | DatePick:18 |
| 55 | home, goals | {…} | date_picker | close | tap | stays | none | host:Host | DatePick:36 |
| 56 | home | {form hosts} | category_picker | category_form | tap | presents(category_form) | category | host:Host | CatPicker:26 |
| 57 | home | {…} | category_picker | row | tap | stays | category | host:Host, category:Category, category_section:CategorySection | CatPicker:36-42 |
| 58 | home | {…} | category_picker | close | tap | stays | none | host:Host | CatPicker:76 |
| 59 | home | {…} | category_form | section | tap | presents(section_picker) | category | entry:CategoryFormEntry | AddCategory:39 |
| 60 | home | {…} | category_form | done | submit | stays | category | category_section:CategorySection, was_inserted:bool, entry:CategoryFormEntry | AddCategory:84-91 |
| 61 | home | {…} | category_form | close | tap | stays | category | has_changes:bool | AddCategory:66 |
| 62 | home, settings | {…, settings.category_form} | section_picker | option | tap | stays | category | category_section:CategorySection | AddCategory:120 |
| 63 | home, settings | {…} | section_picker | close | tap | stays | none | — | AddCategory:110 |
| 64 | home | dashboard | daily_transactions | daily_transaction_form | tap | presents(daily_transaction_form) | daily_transaction | — | DailyList:26 |
| 65 | home | dashboard | daily_transactions | help | tap | presents(daily_intro) | none | — | DailyList:76 |
| 66 | home | dashboard | daily_transactions | close | tap | stays | none | preset_count:int | DailyList:85 |
| 67 | home | dashboard | daily_transactions | preset_row | view | stays | daily_transaction | position:int, amount_bucket:B, category:Category | DailyList:45 |
| 68 | home | dashboard | daily_transactions | preset_row | submit (swipe delete) | stays | daily_transaction | position:int, amount_bucket:B, category:Category | DailyList:49-51 |
| 69 | home | dashboard | daily_transactions | empty_state | view | stays | daily_transaction | — | DailyList:39 |
| 70 | home | dashboard | daily_intro | start | tap | stays | none | is_auto:bool | DailyIntro:49 |
| 71 | home | dashboard | daily_transaction_form | category | tap | presents(category_picker) | category | — | AddDaily:42 |
| 72 | home | dashboard | daily_transaction_form | done | submit | stays | daily_transaction | amount_bucket:B, category:Category, is_valid:bool | AddDaily:52 |
| 73 | home | dashboard | daily_transaction_form | close | tap | stays | daily_transaction | has_changes:bool | AddDaily:84 |
| 74 | home | dashboard | daily_transaction_form | error | view | stays | daily_transaction | reason:ErrorReason | AddDaily:61 |
| 75 | home | transactions | nav | back | tap | navigates(previous) | none | — | TxList:57 |
| 76 | home | transactions | toolbar | transaction_form | tap | presents(transaction_form, create) | transaction | — | TxList:71 |
| 77 | home | transactions | summary | header | view | stays | budget | budget_left_bucket:B, spent_bucket:B | TxList:82 |
| 78 | home | transactions | list | transaction_row | view | stays | transaction | position:int, day_index:int, transaction_type:TransactionType, category:Category, amount_bucket:B | TxList:34 |
| 79 | home | transactions | list | transaction_row | tap | navigates(home.transaction_detail) | transaction | (as 78) | TxList:34 |
| 80 | home | transactions | list | empty_state | view | stays | transaction | — | TxList:26 |
| 81 | home | transaction_detail | nav | back | tap | navigates(previous) | none | — | TxDetail:96 |
| 82 | home | transaction_detail | header | summary | view | stays | transaction | transaction_type:TransactionType, category:Category, amount_bucket:B, has_note:bool | TxDetail:28 |
| 83 | home | transaction_detail | note | card | tap | presents(note_sheet) | transaction | has_note:bool | TxDetail:56 |
| 84 | home | transaction_detail | insights | category_card | view | stays | transaction | is_locked:bool, category:Category | TxInsights:31 |
| 85 | home | transaction_detail | insights | category_card | tap (locked) | presents(insights_info) | transaction | kind:InsightKind | TxInsights:32 |
| 86 | home | transaction_detail | insights | feedback | tap | presents(feedback) | none | topic:FeedbackTopic | TxInsights:55 |
| 87 | home | transaction_detail | insights | daily_card | view | stays | transaction | is_locked:bool | DailyInsights:23 |
| 88 | home | transaction_detail | insights | daily_card | tap (locked) | presents(insights_info) | transaction | kind:InsightKind | DailyInsights:24 |
| 89 | home | transaction_detail | insights | daily_feedback | tap | presents(feedback) | none | topic:FeedbackTopic | DailyInsights:43 |
| 90 | home | transaction_detail | insights_info | primary | tap | stays | none | kind:InsightKind | TxInsights:98; DailyInsights:79 |
| 91 | home | {transaction_detail, payment_detail} | note_sheet | done | submit | stays | transaction / recurring_payment | note_length:int, has_note:bool | TxDetail:140; RpDetail:180 |
| 92 | home | {…} | note_sheet | close | tap | stays | transaction / recurring_payment | has_changes:bool | TxDetail:130; RpDetail:170 |
| 93 | home | transaction_detail | transaction_deletion | primary | tap | navigates(previous) | transaction | transaction_type:TransactionType, amount_bucket:B | Alerts:39,46-52 |
| 94 | home | transaction_detail | transaction_deletion | secondary | tap | stays | transaction | — | Alerts:40 |
| 95 | home | payments | nav | back | tap | navigates(previous) | none | — | RpList:62 |
| 96 | home | payments | toolbar | payment_form | tap | presents(payment_form, create) | recurring_payment | — | RpList:76 |
| 97 | home | payments | calendar | prev_month | tap | reroots | recurring_payment | month_offset:int | RpCalendar:30 |
| 98 | home | payments | calendar | next_month | tap | reroots | recurring_payment | month_offset:int | RpCalendar:40 |
| 99 | home | payments | calendar | day | tap | reroots | recurring_payment | has_payments:bool, day_offset:int | RpCalendar:73 |
| 100 | home | payments | list | payment_row | view | stays | recurring_payment | position:int, periodicity:Periodicity, is_due:bool, has_reminder:bool, amount_bucket:B, category:Category | RpList:41 |
| 101 | home | payments | list | payment_row | tap | navigates(home.payment_detail) | recurring_payment | (as 100) | RpList:41 |
| 102 | home | payments | list | empty_state | view | stays | recurring_payment | — | RpList:52 |
| 103 | home | payment_detail | nav | back | tap | navigates(previous) | none | — | RpDetail:119 |
| 104 | home | payment_detail | header | summary | view | stays | recurring_payment | periodicity:Periodicity, is_due:bool, days_until_due:int, has_reminder:bool, amount_bucket:B, transaction_type:TransactionType, category:Category | RpDetail:32 |
| 105 | home | payment_detail | header | renew | view | stays | recurring_payment | days_until_due:int | RpDetail:46 |
| 106 | home | payment_detail | header | renew | tap | stays | recurring_payment | succeeded:bool, amount_bucket:B, periodicity:Periodicity | RpDetail:47-55,198-207 |
| 107 | home | payment_detail | header | error | view | stays | recurring_payment | reason:ErrorReason | RpDetail:101 |
| 108 | home | payment_detail | note | card | tap | presents(note_sheet) | recurring_payment | has_note:bool | RpDetail:67 |
| 109 | home | payment_detail | reminder | toggle | tap | stays | recurring_payment | is_on:bool, reminder_type:ReminderType | RpDetail:90-97 |
| 110 | home | payment_detail | payment_deletion | primary | tap | navigates(previous) | recurring_payment | is_due:bool, amount_bucket:B | Alerts:39,54-59 |
| 111 | home | payment_detail | payment_deletion | secondary | tap | stays | recurring_payment | — | Alerts:40 |
| 112 | goals | list | summary | total | view | stays | goal | total_saved_bucket:B, goal_count:int | GoalsList:70 |
| 113 | goals | list | list | goal_card | view | stays | goal | position:int, goal_status:GoalStatus, progress:double, days_left:int, amount_bucket:B | GoalsList:58 |
| 114 | goals | list | list | goal_card | tap | navigates(goals.goal_detail) | goal | (as 113) | GoalsList:58 |
| 115 | goals | list | list | empty_state | view | stays | goal | — | GoalsList:54 |
| 116 | goals | goal_detail | nav | back | tap | navigates(previous) | none | — | GoalDetail:38 |
| 117 | goals | goal_detail | progress | summary | view | stays | goal | goal_status:GoalStatus, progress:double, days_left:int, saved_bucket:B, amount_bucket:B, contribution_count:int | GoalDetail:49 |
| 118 | goals | goal_detail | progress | status_card | view | stays | goal | goal_status:GoalStatus | GoalDetail:78-90 |
| 119 | goals | goal_detail | plan | suggestion_card | view | stays | goal | time_unit:TimeUnit, time_units:int | GoalDetail:92 |
| 120 | goals | goal_detail | contributions | contribution_row | view | stays | goal_transaction | position:int, amount_bucket:B | GoalDetail:109 |
| 121 | goals | goal_detail | contributions | empty_state | view | stays | goal_transaction | — | GoalDetail:106 |
| 122 | goals | goal_detail | goal_form | due_date | tap | presents(date_picker) | goal | mode:FormMode | AddGoal:48; EditGoal:39 |
| 123 | goals | goal_detail | goal_form | estimate | tap | stays | goal | success_rate:SuccessRate | Estimator:110 |
| 124 | goals | goal_detail | goal_form | done | submit | stays | goal (create/edit) / goal_transaction (add_funds) | mode:FormMode, amount_bucket:B, days_left:int, remaining_bucket:B, is_valid:bool, has_changes:bool | AddGoal:61; EditGoal:50; AddContrib:40 |
| 125 | goals | goal_detail | goal_form | close | tap | stays | goal / goal_transaction | mode:FormMode, has_changes:bool | AddGoal:92; EditGoal:83; AddContrib:67 |
| 126 | goals | goal_detail | goal_form | error | view | stays | goal / goal_transaction | mode:FormMode, reason:ErrorReason | AddGoal:70; EditGoal:65; AddContrib:46 |
| 127 | goals | goal_detail | goal_deletion | primary | tap | navigates(previous) | goal | goal_status:GoalStatus, contribution_count:int | Alerts:39,60-65 |
| 128 | goals | goal_detail | goal_deletion | secondary | tap | stays | goal | — | Alerts:40 |
| 129 | overview | dashboard | top_category | card | view | stays | transaction | category:Category, top_category_share:double | Overview:134 |
| 130 | overview | dashboard | top_category | card | tap | navigates(overview.top_category) | transaction | (as 129) | Overview:134 |
| 131 | overview | dashboard | top_category | locked_card | view | stays | transaction | spendings_count:int | Overview:141 |
| 132 | overview | dashboard | top_category | locked_card | tap | presents(top_category_info) | transaction | spendings_count:int | Overview:141 |
| 133 | overview | dashboard | month_recap | card | view | stays | budget | — | Overview:152 |
| 134 | overview | dashboard | month_recap | card | tap | navigates(overview.month_recap) | budget | — | Overview:152 |
| 135 | overview | dashboard | month_recap | locked_card | view | stays | budget | — | Overview:149 |
| 136 | overview | dashboard | month_recap | locked_card | tap | presents(month_recap_info) | budget | — | Overview:149 |
| 137 | overview | dashboard | updates | info_card | view | stays | none | — | Overview:37 |
| 138 | overview | dashboard | top_category_info | primary | tap | navigates(overview.top_category) | transaction | is_demo:bool | Overview:47-52 |
| 139 | overview | dashboard | month_recap_info | primary | tap | navigates(overview.month_recap) | budget | is_demo:bool | Overview:76-81 |
| 140 | overview | top_category | nav | back | tap | navigates(previous) | none | — | TopCat:109 |
| 141 | overview | top_category | toolbar | feedback | tap | presents(feedback) | none | topic:FeedbackTopic | TopCat:118-121 |
| 142 | overview | top_category | summary | top_card | view | stays | transaction | is_locked:bool, category:Category, top_category_share:double, transaction_count:int | TopCat:21-75 |
| 143 | overview | top_category | other_categories | bar | view | stays | transaction | position:int, category:Category, share:double | TopCat:86 |
| 144 | overview | month_recap | nav | back | tap | navigates(previous) | none | — | Recap:46 |
| 145 | overview | month_recap | toolbar | feedback | tap | presents(feedback) | none | topic:FeedbackTopic | Recap:55-58 |
| 146 | overview | month_recap | budget | chart | view | stays | budget | is_locked:bool, unused_bucket:B | Recap:96-150 |
| 147 | overview | month_recap | categories | learn_more | tap | presents(category_breakdown) | transaction | section_count:int | Recap:160 |
| 148 | overview | month_recap | categories | empty_state | view | stays | transaction | — | Recap:206 |
| 149 | overview | month_recap | goals | summary | view | stays | goal_transaction | contribution_bucket:B, goal_count:int | Recap:220 |
| 150 | overview | month_recap | goals | empty_state | view | stays | goal_transaction | — | Recap:250 |
| 151 | overview | month_recap | category_breakdown | section_card | view | stays | transaction | category_section:CategorySection, category:Category | Breakdown:55 |
| 152 | home, overview | {transaction_detail, top_category, month_recap} | feedback | send | submit | stays | none | topic:FeedbackTopic, entry:FeedbackEntry, message_length:int, has_email:bool | Contact:93-100 |
| 153 | home, overview | {…} | feedback | close | tap | stays | none | topic:FeedbackTopic, has_changes:bool | Contact:75 |
| 154 | settings | root | nav | back | tap | navigates(previous) | none | — | Settings:80 |
| 155 | settings | root | menu | categories | tap | navigates(settings.categories) | category | — | Settings:38 |
| 156 | settings | root | menu | reminders | tap | navigates(settings.reminders) | recurring_payment | — | Settings:42 |
| 157 | settings | root | menu | general | tap | navigates(settings.app) | account | — | Settings:48 |
| 158 | settings | root | menu | reset | tap | navigates(settings.reset) | account | — | Settings:52 |
| 159 | settings | root | menu | contact | tap | navigates(settings.feedback) | none | topic:FeedbackTopic | Settings:58 |
| 160 | settings | root | menu | rate_app | tap | stays | none | — | Settings:62,136 |
| 161 | settings | root | menu | features_hub | tap | presents(features_hub) | none | — | Settings:67,137 |
| 162 | settings | app | nav | back | tap | navigates(previous) | none | — | AppSettings:36 |
| 163 | settings | app | menu | currency | tap | navigates(settings.currency) | account | — | AppSettings:18 |
| 164 | settings | currency | nav | back | tap | navigates(previous) | none | — | Currency:46 |
| 165 | settings | currency | list | currency_cell | tap | stays (+ `session_update{currency}`) | account | is_changed:bool | Currency:28-30 |
| 166 | settings | categories | nav | back | tap | navigates(previous) | none | — | Categories:68 |
| 167 | settings | categories | toolbar | category_form | tap | navigates(settings.category_form) | category | — | Categories:19 |
| 168 | settings | categories | list | category_row | view | stays | category | category:Category, category_tag:CategoryTag, category_section:CategorySection | Categories:33 |
| 169 | settings | categories | list | category_row | submit (swipe delete) | stays | category | (as 168) | Categories:35 |
| 170 | settings | category_form | nav | back | tap | navigates(previous) | category | has_changes:bool | AddCategory:74 |
| 171 | settings | category_form | details | section | tap | presents(section_picker) | category | — | AddCategory:39 |
| 172 | settings | category_form | toolbar | done | submit | navigates(previous) | category | category_section:CategorySection, was_inserted:bool | AddCategory:84-91 |
| 173 | settings | reminders | nav | back | tap | navigates(previous) | none | — | Reminders:95 |
| 174 | settings | reminders | general | notifications | tap | stays (+ `session_update{notifications_enabled}`) | account | is_on:bool | Reminders:31-50 |
| 175 | settings | reminders | reminders | reset_button | tap | presents(reminders_reset) | recurring_payment | — | Reminders:59 |
| 176 | settings | reminders | reminders_reset | primary | tap | stays | recurring_payment | — | Reminders:146-148 |
| 177 | settings | reminders | reminders_reset | secondary | tap | stays | recurring_payment | — | Reminders:139 |
| 178 | settings | reset | nav | back | tap | navigates(previous) | none | — | Erase:52 |
| 179 | settings | reset | danger | reset_button | tap | presents(reset_confirm) | account | — | Erase:27 |
| 180 | settings | reset | reset_confirm | primary | tap | navigates(onboarding.intro) (+ `session_update`) | account | — | Erase:102-104,120-132 |
| 181 | settings | reset | reset_confirm | secondary | tap | stays | account | — | Erase:95 |
| 182 | settings | feedback | nav | back | tap | navigates(previous) | none | has_changes:bool | Contact:83 |
| 183 | settings | feedback | toolbar | send | submit | navigates(previous) | none | topic:FeedbackTopic, message_length:int, has_email:bool | Contact:93-100,55-60 |
| 184 | onboarding | intro | pager | feature_page | view | stays | none | feature:Feature, position:int | Onboarding:28-31 |
| 185 | onboarding | intro | footer | start | tap | presents(permissions) | none | pages_seen:int | Onboarding:49 |
| 186 | onboarding | intro | permissions | system_prompt | view | stays | account | granted:bool | Permissions:93-105 |
| 187 | onboarding | intro | permissions | notifications | tap | stays | account | is_on:bool | Permissions:42-59 |
| 188 | onboarding | intro | permissions | currency | tap | presents(currency_picker) | account | — | Permissions:60-63 |
| 189 | onboarding | intro | permissions | finish | submit | navigates(home.dashboard) (+ `session_update`) | account | notifications_on:bool | Permissions:73-83 |
| 190 | onboarding | intro | currency_picker | currency_cell | tap | stays | account | is_changed:bool | Permissions:131-135 |
| 191 | onboarding | intro | currency_picker | close | tap | stays | none | — | Permissions:151 |

**Final counts (re-verified):** 191 spec rows over 172 distinct elements.

| Breakdown | Counts |
|---|---|
| By layer | shell 16, home 95, goals 17, overview 25 (including the 2 feedback rows shared with home), settings 30, onboarding 8 |
| By interaction | tap 129, view 49, submit 13 |
| By effect | stays 102, presents 45, navigates 41, reroots 3 |
| By domain | recurring_payment 38, transaction 37, budget 16, category 16, goal 13, account 13, daily_transaction 9, goal_transaction 8, none 41. Rows with two domains (by host or mode) are counted once, under the domain the table's matching rule picks first |

**Implied declarations:** 19 screen views, 28 presentation views, plus `session_init` and `session_update`.
