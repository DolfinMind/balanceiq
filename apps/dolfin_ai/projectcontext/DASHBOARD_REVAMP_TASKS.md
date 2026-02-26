# Dashboard Revamp Tasks

> Each task = 1 commit. Commit message format: `dashboard-revamp: <task description>`

## Code Audit Findings

Before starting the revamp, these redundancies were identified:

| Finding | File | Detail |
|---|---|---|
| 🗑️ Orphan widget | `biggest_category_widget.dart` | Never imported or used anywhere |
| 🐛 Hardcoded currency | `accounts_breakdown_widget.dart` | Uses `'BDT $total'` instead of `CurrencyCubit` |
| 🐛 Hardcoded currency | `biggest_category_widget.dart` | Uses `'\$$amount'` instead of `CurrencyCubit` |
| ⚠️ Dead API fields | `DashboardSummary` entity | `incomeTransactions`, `expenseTransactions`, `avgIncome`, `avgExpense` always 0 |
| ⚠️ Empty field | `expenseAccount` | Always empty string from API |
| 🎨 Glassmorphism | `home_appbar.dart`, `balance_card_widget.dart` | `ThemedGlass` (3 usages) |
| 🎨 Heavy effects | `category_breakdown_widget.dart` | `BackdropFilter`, gradients, glow shadows |
| 🎨 Heavy effects | `spending_trend_chart.dart` | Gradient border, fill, `BackdropFilter` |
| 🎨 Heavy effects | `home_page.dart` exit dialog | `BackdropFilter` + glass styling |

---

## Tasks

### Phase 1: Cleanup & Foundation

- [ ] **Task 1: Remove orphan widget and fix hardcoded currencies**
  - Delete `biggest_category_widget.dart` (unused orphan)
  - Fix `accounts_breakdown_widget.dart`: replace `'BDT $total'` with `CurrencyCubit.formatAmount()`
  - Commit: `dashboard-revamp: remove orphan widget, fix hardcoded currencies`

- [ ] **Task 2: Clean up DashboardLayout — standardize spacing**
  - Replace mixed `SizedBox(height: 8)` / `SizedBox(height: 16)` with consistent 16px spacing
  - Standardize horizontal padding to 16px throughout
  - Commit: `dashboard-revamp: standardize layout spacing`

### Phase 2: AppBar & Balance Card

- [ ] **Task 3: Revamp HomeAppbar — remove glass, flatten design**
  - Remove all `ThemedGlass.container` usages (date selector, theme toggle)
  - Replace with flat `Container` using `colorScheme.surfaceContainerLow`
  - Replace gradient profile icon border with solid `primary` color
  - Commit: `dashboard-revamp: flatten appbar, remove glass effects`

- [ ] **Task 4: Revamp BalanceCard — remove gradients and glass**
  - Remove `ShaderMask` gradient on net balance text → solid `onSurface` color
  - Remove `BoxShadow` glow effect on balance section
  - Replace `ThemedGlass.container` on income/expense cards → flat `Container`
  - Remove gradient icon circles → solid muted-color circles
  - Remove bottom indicator bars
  - Commit: `dashboard-revamp: flatten balance card, remove gradients`

### Phase 3: Spending-Focused Widgets (Elevated Priority)

- [ ] **Task 5: Revamp CategoryBreakdownWidget — clean, prominent design**
  - Remove `BackdropFilter`, `LinearGradient`, glow `BoxShadow`
  - Redesign cards: flat background, clean icon containers, no gradient
  - Remove gradient count badge → simple flat pill badge
  - Make category cards more prominent (increase font size, tighter spacing)
  - Keep `GestureDetector` tap-to-navigate to `TransactionsPage`
  - Commit: `dashboard-revamp: clean category breakdown, elevate spending visibility`

- [ ] **Task 6: Revamp TransactionHistoryWidget — clean, prominent design**
  - Remove `Ink` widget with border/shadows → simple flat row containers
  - Increase item count from 3 to 5 for more visibility
  - Clean up icon styling (remove shadow effects)
  - Keep transaction detail modal navigation
  - Commit: `dashboard-revamp: clean transaction history, show more items`

- [ ] **Task 7: Reorder DashboardLayout — spending sections higher**
  - Move `CategoryBreakdownWidget` higher in the scroll (after AnalysisCarousel)
  - Move `TransactionHistoryWidget` up (after CategoryBreakdown)
  - Push `FinancialRatiosWidget`, `AccountsBreakdownWidget`, `BiggestIncome/Expense` lower
  - Commit: `dashboard-revamp: reorder layout, prioritize spending sections`

### Phase 4: Charts & Analysis

- [ ] **Task 8: Revamp SpendingTrendChart — flatten**
  - Remove gradient border decoration
  - Remove `BackdropFilter`
  - Remove gradient `belowBarData` fill → transparent or very subtle solid fill
  - Use flat `surfaceContainerLow` background
  - Keep all chart interaction logic (tooltips, haptics)
  - Commit: `dashboard-revamp: flatten spending trend chart`

- [ ] **Task 9: Revamp IncomeExpensePieChart & CategoryBarChart — flatten**
  - Remove any gradient or glow effects
  - Use flat solid colors for chart segments/bars
  - Clean container styling
  - Commit: `dashboard-revamp: flatten pie chart and bar chart`

- [ ] **Task 10: Clean AnalysisCarousel container**
  - Ensure carousel wrapper has clean flat styling
  - Keep animated page indicator dots
  - Commit: `dashboard-revamp: clean analysis carousel container`

### Phase 5: Remaining Widgets

- [ ] **Task 11: Revamp AccountsBreakdownWidget — flat list**
  - Remove neumorphism `BoxShadow` (dual light/dark shadows)
  - Replace with flat card: `surfaceContainerLow` background, subtle border
  - Fix hardcoded 'BDT' (already done in Task 1, verify)
  - Commit: `dashboard-revamp: flatten accounts breakdown`

- [ ] **Task 12: Revamp FinancialRatiosWidget — accent bar cards**
  - Replace colored background with flat `surfaceContainerLow`
  - Add thin 3px left-side accent bar (red for expense ratio, green for savings)
  - Commit: `dashboard-revamp: flatten financial ratio cards`

- [ ] **Task 13: Clean BiggestIncome & BiggestExpense widgets**
  - Replace `surface.withOpacity(0.7)` → solid `surfaceContainerLow`
  - Clean icon circle styling
  - Commit: `dashboard-revamp: clean biggest income/expense widgets`

### Phase 6: Shimmer, Chat Button & Exit Dialog

- [ ] **Task 14: Revamp FloatingChatButton — flat design**
  - Remove any glass/gradient effects
  - Use flat `surfaceContainer` background with subtle elevation
  - Commit: `dashboard-revamp: flatten floating chat button`

- [ ] **Task 15: Update DashboardShimmer — match new layout**
  - Update shimmer placeholder dimensions/order to match new layout
  - Remove accounts breakdown shimmer section if not prominently visible
  - Commit: `dashboard-revamp: update shimmer to match new layout`

- [ ] **Task 16: Clean exit dialog — remove BackdropFilter**
  - Replace glassmorphism exit dialog with simple `AlertDialog` or clean `Dialog`
  - Remove `BackdropFilter`, gradient borders
  - Commit: `dashboard-revamp: clean exit dialog`

### Phase 7: Final Polish

- [ ] **Task 17: Review dark/light theme consistency**
  - Verify all widgets use `colorScheme` tokens consistently
  - Test both dark and light mode
  - Ensure no hardcoded colors remain
  - Commit: `dashboard-revamp: theme consistency pass`

---

## Summary

| Metric | Value |
|---|---|
| Total tasks | 17 |
| Files modified | ~16 |
| Files deleted | 1 (`biggest_category_widget.dart`) |
| New files | 0 |
| Breaking changes | None (UI-only, same data model) |
