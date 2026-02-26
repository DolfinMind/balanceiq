# Dashboard Revamp Plan — Feb 27, 2026

## Design Philosophy

**Goal**: Transform the dashboard from a heavy glassmorphism/gradient-based UI into a **fresh, clean, clutter-free** interface.

**Principles**:
- **Flat design** — No gradients, no glassmorphism, no glow effects
- **Generous whitespace** — Let content breathe
- **Subtle depth** — Use only light elevation/shadows (no `ShaderMask`, no `ThemedGlass`)
- **Typography-driven hierarchy** — Bold numbers, lightweight labels
- **Color restraint** — Monochrome base (surface colors) with accent colors only for income (green) and expense (red)
- **Content density reduction** — Show only essential metrics at a glance; secondary data should be discoverable, not forced
- **Spending-first layout** — Category breakdown and recent transactions should be prominently visible, placed higher in the scroll order

---

## Code Audit Findings

| Finding | File | Detail |
|---|---|---|
| 🗑️ Orphan widget | `biggest_category_widget.dart` | Never imported or used anywhere — DELETE |
| 🐛 Hardcoded currency | `accounts_breakdown_widget.dart` | Uses `'BDT $total'` instead of `CurrencyCubit` |
| 🐛 Hardcoded currency | `biggest_category_widget.dart` | Uses `'\$$amount'` instead of `CurrencyCubit` |
| ⚠️ Dead API fields | `DashboardSummary` entity | `incomeTransactions`, `expenseTransactions`, `avgIncome`, `avgExpense` always 0 |
| ⚠️ Empty field | `expenseAccount` | Always empty string from API |
| 🎨 Glassmorphism | `home_appbar.dart`, `balance_card_widget.dart` | `ThemedGlass` (3 usages) |
| 🎨 Heavy effects | `category_breakdown_widget.dart` | `BackdropFilter`, gradients, glow shadows |
| 🎨 Heavy effects | `spending_trend_chart.dart` | Gradient border, fill, `BackdropFilter` |
| 🎨 Heavy effects | `home_page.dart` exit dialog | `BackdropFilter` + glass styling |

---

## Current vs. New Design Reference

### Current Design
![Current Dashboard](file:///Users/sifatullahchowdhury/Projects/Applications/dolfin_workspace/apps/dolfin_ai/projectcontext/design_files/dashboard/screen.png)

### New Design Direction (v2 — spending focus)
![Revamp Mockup v2](file:///Users/sifatullahchowdhury/Projects/Applications/dolfin_workspace/apps/dolfin_ai/projectcontext/design_files/dashboard/revamp_mockup_v2.png)

---

## Widget-by-Widget Changes

### 1. AppBar (`home_appbar.dart`)

| Aspect | Current | New |
|---|---|---|
| Profile icon | Gradient border `LinearGradient` | Solid `primary` color border or no border |
| Date selector | `ThemedGlass.container` with glass preset | Simple `Container` with `surface` background + subtle border |
| Theme toggle | `ThemedGlass.container` wrapping icon | Plain `IconButton` or minimal circular container |
| Overall feel | Glassmorphism everywhere | Flat, clean, M3-style AppBar |

**Key removals**: `ThemedGlass`, `GlassPreset.subtle`, `LinearGradient` on profile

---

### 2. Balance Card (`balance_card_widget.dart`)

| Aspect | Current | New |
|---|---|---|
| Net balance text | `ShaderMask` with gradient colors | Solid `onSurface` color, large clean font |
| Balance glow | `BoxShadow` with primary color glow | Remove entirely |
| Income/Expense cards | `ThemedGlass.container` with `GlassPreset.medium` | Flat `Container` with `surfaceContainerLow` fill + 12px border radius |
| Icon containers | Gradient circles with `BoxShadow` glow | Solid muted-color circles, no shadow |
| Bottom indicator bar | Colored bar under each card | Remove (reduces clutter) |

**Key removals**: `ShaderMask`, `ThemedGlass`, `GlassPreset`, `LinearGradient`, box shadow glows

---

### 3. Financial Ratios (`financial_ratio_widget.dart`)

| Aspect | Current | New |
|---|---|---|
| Layout | Two colored boxes side-by-side | Two flat cards with a thin left-side accent bar (2-3px) |
| Background | `colorScheme.error.withOpacity(0.15)` | Use `surfaceContainerLow` for both, differentiate with accent bar |
| Typography | Standard heading | Clean: small label on top, large bold percentage below |

---

### 4. Analysis Carousel (`analysis_carousel.dart` + charts)

| Aspect | Current | New |
|---|---|---|
| Container | Full-width cards | Flat container with subtle border, no shadows |
| Chart styling | Default fl_chart styling | Simplified — thinner lines, muted grid, no fills |
| Page indicator | Standard dots | Minimal pill-dots (keep current animated style) |
| Height | 220px fixed | Keep similar, ensure proper spacing |

**Chart-specific changes** (all 3 charts):
- `spending_trend_chart.dart` — Remove any gradient fills beneath the line, use a single solid thin stroke
- `income_expense_pie_chart.dart` — Use flat solid colors, no glow or shadow on segments
- `category_bar_chart.dart` — Simple flat bars with muted palette

---

### 5. Accounts Breakdown (`accounts_breakdown_widget.dart`)

| Aspect | Current | New |
|---|---|---|
| Style | "Minimalist Neumorphism" per docstring | Truly flat list items |
| Item layout | Cards with shadows and colored accents | Clean list rows with thin left-side color bar (3px) |
| Container | Padded card containers | Simple `Column` with `Divider` between items or light border |

---

### 6. Biggest Income / Expense (`biggest_income_widget.dart`, `biggest_expense_widget.dart`)

| Aspect | Current | New |
|---|---|---|
| Container | Surface with 0.7 opacity | Flat `surfaceContainerLow` background |
| Icon circle | Colored circle with opacity background | Solid muted circle |
| Amount color | Green/red with 0.8 opacity | Clean green/red accent (full opacity) |
| Layout | Row with icon, text, amount | Keep same row layout (it's already clean) |

---

### 7. Category Breakdown (`category_breakdown_widget.dart`)

| Aspect | Current | New |
|---|---|---|
| Container | Heavy styled cards | Simple flat list |
| Visuals | Multiple decorative elements | Clean rows: category name, thin progress bar, amount |

---

### 8. Transaction History (`transaction_history_widget.dart`)

| Aspect | Current | New |
|---|---|---|
| Header | Styled header with "View All" | Clean section title with subtle "View All" text button |
| Items | Styled rows | Clean minimal rows: icon, title/subtitle, amount aligned right |
| Dividers | Between items | Thin `Divider` or spacing between items |

---

### 9. Floating Chat Button (`floating_chat_button.dart`)

| Aspect | Current | New |
|---|---|---|
| Container | Styled with possible glass effects | Clean flat `surfaceContainer` background + subtle elevation (2-4dp) |
| Input hint | Current styling | Clean text, muted color |
| Send button | Current icon button | Flat filled tonal button |

---

### 10. Dashboard Layout (`dashboard_layout.dart`)

| Aspect | Current | New |
|---|---|---|
| Pull-to-refresh | `LiquidPullToRefresh` | **Keep** `LiquidPullToRefresh` (user preference) |
| Spacing | Mixed 8px/16px `SizedBox` spacers | Consistent 16px vertical spacing throughout |
| Scroll view | `CustomScrollView` with Slivers | Keep `CustomScrollView` (performance), standardize padding |
| **Widget order** | Balance → Charts → Ratios → Accounts → BiggestItems → Categories → Transactions | Balance → Charts → **Categories → Transactions** → Ratios → Accounts → BiggestItems |

---

### 11. Dashboard Shimmer (`dashboard_shimmer.dart`)

| Aspect | Current | New |
|---|---|---|
| Style | Current shimmer loading | Match new flat card dimensions for seamless loading states |

---

## New Design Tokens

These are the surface/color tokens to use consistently (from M3):

| Token | Light Mode Usage | Dark Mode Usage |
|---|---|---|
| `scaffoldBackgroundColor` | White (`#FFFFFF`) | Near-black (`#121212`) |
| `surface` | White | Dark surface (`#1E1E1E`) |
| `surfaceContainerLow` | Very light gray (`#F5F5F5`) | Slightly lighter dark (`#252525`) |
| `surfaceContainer` | Light gray (`#EEEEEE`) | Medium dark (`#2C2C2C`) |
| `onSurface` | Near-black text | White/near-white text |
| `onSurfaceVariant` | Gray text for labels | Muted white for labels |
| `primary` | App primary (for interactive elements only) | Same |
| Income accent | `#34C759` (green) | `#30D158` |
| Expense accent | `#FF3B30` (red) | `#FF453A` |

---

## Implementation Phases

### Phase 1: Foundation (Layout + AppBar + Balance Card)
**Files to modify**:
- `dashboard_layout.dart` — Replace `LiquidPullToRefresh` with `RefreshIndicator`, standardize spacing
- `home_appbar.dart` — Remove all `ThemedGlass`, replace with flat containers
- `balance_card_widget.dart` — Remove `ShaderMask`, `ThemedGlass`, gradients, box shadows

### Phase 2: Metrics Cards (Ratios + Biggest Items)
**Files to modify**:
- `financial_ratio_widget.dart` — Flat cards with accent bars
- `biggest_income_widget.dart` — Simplify icon styling
- `biggest_expense_widget.dart` — Simplify icon styling

### Phase 3: Charts & Analysis
**Files to modify**:
- `analysis_carousel.dart` — Clean container
- `spending_trend_chart.dart` — Remove gradient fills, simplify to thin strokes
- `income_expense_pie_chart.dart` — Flat solid colors
- `category_bar_chart.dart` — Simple flat bars

### Phase 4: Lists & Breakdowns
**Files to modify**:
- `accounts_breakdown_widget.dart` — Flat list with accent bars
- `category_breakdown_widget.dart` — Clean flat list
- `transaction_history_widget.dart` — Minimal clean rows

### Phase 5: Chat Button & Shimmer
**Files to modify**:
- `floating_chat_button.dart` — Flat design, remove glass effects
- `dashboard_shimmer.dart` — Match new flat card dimensions

---

## Files Summary

| Category | Files | Action |
|---|---|---|
| Layout | `dashboard_layout.dart` | Modify (replace pull-to-refresh, spacing) |
| AppBar | `home_appbar.dart` | Modify (remove glass) |
| Balance | `balance_card_widget.dart` | Modify (remove gradients/glass) |
| Ratios | `financial_ratio_widget.dart` | Modify (flat cards) |
| Income/Expense | `biggest_income_widget.dart`, `biggest_expense_widget.dart` | Modify (simplify) |
| Charts | `analysis_carousel.dart`, `spending_trend_chart.dart`, `income_expense_pie_chart.dart`, `category_bar_chart.dart` | Modify (flatten) |
| Breakdowns | `accounts_breakdown_widget.dart`, `category_breakdown_widget.dart` | Modify (flat lists) |
| Transactions | `transaction_history_widget.dart` | Modify (clean rows) |
| Chat | `floating_chat_button.dart` | Modify (flat container) |
| Loading | `dashboard_shimmer.dart` | Modify (match new layout) |
| **Total** | **16 files** | **All modifications, no new/deleted files** |

---

## Testing Strategy

- **Unit tests**: Existing cubit/repository tests are unaffected (no logic changes)
- **Visual testing**: Manual verification on device after each phase
- **Both themes**: Verify light and dark mode after every phase
- **No regressions**: Ensure all data displays correctly, pull-to-refresh works, navigation intact

---

## Key Dependencies to Remove/Replace

| Dependency | Current Usage | Replacement |
|---|---|---|
| `ThemedGlass` / `GlassPreset` | AppBar, Balance Card, other containers | Standard `Container` with `colorScheme.surface*` |
| `ShaderMask` + `LinearGradient` | Balance amount text | Plain `Text` with solid color |
| `LiquidPullToRefresh` | Dashboard pull-to-refresh | **Keep** (user preference) |
| Gradient `BoxDecoration` | Profile icon, income/expense icons | Solid color `BoxDecoration` |
| Glow `BoxShadow` | Balance section, icon highlights | Remove or replace with minimal elevation shadow |

> [!NOTE]
> Full task list with individual commit boundaries is in [DASHBOARD_REVAMP_TASKS.md](file:///Users/sifatullahchowdhury/Projects/Applications/dolfin_workspace/apps/dolfin_ai/projectcontext/DASHBOARD_REVAMP_TASKS.md)
