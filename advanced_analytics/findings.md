# Advanced Analytics — Findings

Advanced analytics on the Olist Gold layer (SQL Server), covering 6 business questions using CTEs and window functions. Full queries: [`advanced_analytics_queries.sql`](./advanced_analytics_queries.sql)

### Contents
1. [Are customers coming back?](#q1-are-customers-coming-back)
2. [Which sellers are reliable long-term vs. one-hit wonders?](#q2-which-sellers-are-reliable-long-term-vs-one-hit-wonders)
3. [Is delivery getting better or worse, and where?](#q3-is-delivery-getting-better-or-worse-and-where)
4. [Which product categories are rising and which are dying?](#q4-which-product-categories-are-rising-and-which-are-dying)
5. [Who are the actual high-value customers?](#q5-who-are-the-actual-high-value-customers)
6. [Does payment method say anything about spend?](#q6-does-payment-method-say-anything-about-spend)

---

## Q1: Are customers coming back?

**12.4% of customers are repeat buyers, contributing 11.1% of revenue.**

Repeat customers: 11,610 out of ~93,358 total (12.4%), contributing 11.1% of total revenue. Repeat buyers have a slightly lower average order value than first-time buyers, not higher.

This is much higher than the 2.6% repeat rate from the EDA project. The difference comes from `customer_id` being assigned per order in this dataset, not per person — grouping by it treats every order as a separate customer. `customer_unique_id` is the correct person-level identifier and gives the accurate rate.

Repeat rate by first-purchase cohort month stays around 13-14% through 2017, then drops to 9-11% by mid-2018. This is likely not a real decline — later cohorts have had less time in the dataset to make a second purchase, so their repeat rate reads artificially low (right-censoring). December 2017 also dips lower (10.85%) than surrounding months, possibly due to one-time holiday shoppers, though this isn't confirmed.

## Q2: Which sellers are reliable long-term vs. one-hit wonders?

**"Reliable" sellers are the smallest tier by revenue — consistency and scale don't go together here.**

Sellers were grouped into four tiers based on active months and revenue consistency (coefficient of variation):

| Tier | Sellers | Revenue |
|---|---|---|
| Moderate | 844 | ₹68 lakh |
| Volatile | 554 | ₹39.6 lakh |
| Reliable | 416 | ₹19 lakh |
| One-Hit Wonder | 1,156 | ₹5.5 lakh |

Moderate sellers drive the most revenue. The Reliable tier is the smallest by both seller count and revenue — the longer a seller stays active, the more chances there are for month-to-month revenue to vary, so low volatility becomes harder to maintain over time. Reliable means predictable, not high-volume.

Volatile sellers are active for a similar length of time as Moderate sellers (~8 months average) and still generate significant revenue (₹39.6 lakh) — they're inconsistent, not short-lived. One-Hit Wonders are the largest group by count (1,156) but a small share of revenue, active for about a month each.

## Q3: Is delivery getting better or worse, and where?

**Delivery has improved sharply platform-wide since April 2018, but a cluster of Northeast/North states remain consistently poor performers.**

Average delivery time worsened through late 2017 into early 2018 (peaking at 15-17 days, with late rate hitting 20.5% in March 2018), then improved steadily from April 2018 onward, reaching 7.6 days average by August 2018.

By state:
- AL has the worst late-delivery rate (24.1%), consistent with the EDA project's finding. The monthly trend for AL doesn't show steady improvement — it swings between 0% and 45% late month to month.
- Northeast/North states dominate the worst-performing end: MA, SE, PI, CE, BA, PA, TO, PB, RN, PE all exceed ~10% late rate — a geographic pattern that points to regional logistics constraints rather than isolated cases.
- SP has the highest order volume (46,448) and one of the best late rates (5.8%), likely due to seller concentration and shorter shipping distances.
- AC has the lowest late rate (3.3%) but a small sample (91 orders) — not enough volume to call it the best-performing state with confidence.

## Q4: Which product categories are rising and which are dying?

**A handful of "top growth" categories are misleading due to tiny 2017 bases — the meaningful risers and decliners are the ones with real revenue behind the percentage change.**

Comparing 2018 to 2017 revenue by category and ranking by growth surfaces a data-quality issue first: some top "growth" categories started from almost nothing. `small_appliances_home_oven_and_coffee` shows 6,140% growth, but that's ₹735 → ₹45,855 — accurate but not meaningful at that scale.

Categories with real growth behind them: `construction_tools_construction` (₹19K→₹123K), `home_appliances_2` (₹21K→₹87K), `electronics` (₹55K→₹100K), `housewares` (₹223K→₹392K).

Categories with meaningful declines from a substantial base: `computers` (₹156K→₹62K), `toys` (₹299K→₹168K), `cool_stuff` (₹381K→₹228K).

`computers`, `toys`, and `cool_stuff` all declined while `computers_accessories` and `electronics` grew over the same period — possibly a substitution effect, where spend is shifting between related categories rather than dropping overall.

## Q5: Who are the actual high-value customers?

**Champions (loyal, recent buyers) are the smallest and lowest-revenue segment — most revenue comes from one-time big-ticket buyers, not repeat customers.**

RFM (Recency, Frequency, Monetary) built per customer, anchored to the latest order date in the dataset instead of the real current date, since this is historical data.

Sorting by monetary value alone is misleading — nearly all top spenders bought only once, typically on high-value items (furniture, electronics), not through repeated purchases.

Customers were segmented into five groups:

| Segment | Customers | Revenue | Avg Spend |
|---|---|---|---|
| Lost / Low-Value | 69,954 | ₹75.2 lakh | ₹107 |
| High-Value One-Timer | 2,699 | ₹25.0 lakh | ₹924 |
| New Customer | 17,904 | ₹24.8 lakh | ₹139 |
| At Risk (Repeat but inactive) | 1,564 | ₹4.0 lakh | ₹253 |
| Champion | 1,237 | ₹3.3 lakh | ₹269 |

Champions are the smallest segment by both customer count and revenue. Most of Olist's revenue is driven by one-time big-ticket purchases rather than a loyal repeat base — a standard loyalty program built around existing Champions likely has less impact than converting High-Value One-Timers into repeat buyers, since they already spend significantly and simply haven't returned.

The ₹500 cutoff used for "High-Value One-Timer" was checked against the segment's actual average spend (₹924), so the threshold holds up reasonably well.

## Q6: Does payment method say anything about spend?

**Installments are only available on credit card, and higher installment counts line up clearly with larger orders.**

| Payment Type | Orders | Revenue | Avg Order Value | Avg Installments | % of Revenue |
|---|---|---|---|---|---|
| Credit Card | 76,795 | ₹1.25 Cr | ₹163 | 3.5 | 78.3% |
| Boleto | 19,784 | ₹28.7 L | ₹145 | 1 | 17.9% |
| Voucher | 5,769 | ₹3.8 L | ₹66 | 1 | 2.4% |
| Debit Card | 1,529 | ₹2.2 L | ₹143 | 1 | 1.4% |

Credit card accounts for 78% of revenue and is the only payment type with installment support — boleto, voucher, and debit card are single-payment methods in this dataset. So installment usage isn't a preference customers exercise across payment types; it's exclusive to credit card.

Within credit card orders, average order value rises steadily with installment count — from ₹96 (1 installment) to ₹415 (10 installments) — confirming that installments are used for larger purchases specifically. This holds reliably for 1-10 installments, where order volume is high; beyond 10 installments, order counts drop into single digits and the trend becomes unreliable. Voucher has the lowest average order value of any payment type, consistent with use for small or promotional purchases.

---


