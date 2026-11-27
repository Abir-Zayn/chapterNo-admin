# 05 — Subscription and ChapterCoin Domain

## 1. Purpose

This domain controls what a student is entitled to use, how usage allowances are consumed, and how optional ChapterCoin balances are earned or spent.

It must protect both business sustainability and fair student access.

## 2. Core concepts

### Plan
A named access package assigned to a student. **Free** and **Plus** are the baseline names.

### Entitlement
A permission to use a feature or access content under defined conditions.

### Quota
A bounded allowance for an action over a defined time window, such as per day or per month.

### ChapterCoin
A utility balance for optional eligible usage beyond included allowances. It is not withdrawable cash and cannot buy academic advantage.

### Coin transaction
An auditable credit or debit event with a reason, amount, reference, and idempotency protection.

### Question-bank entitlement
A separate permission to access a purchased or assigned teacher question bank. It is not automatically included in Plus.

## 3. Plan principles

- Free must provide a meaningful learning experience.
- Plus offers broader supported learning access and larger fair-use allowances.
- Never advertise unlimited AI.
- Plan access and quotas must be configurable and versioned.
- Subscription status must be verified through the approved purchase provider.
- The client may display entitlements but must not be the authority for them.

The student feature specification includes proposed numeric limits for AI, practice, routines, devices, and history. Those values should be treated as a documented baseline proposal until explicitly approved for production.

## 4. ChapterCoin principles

ChapterCoins can support eligible optional usage beyond plan quotas. They must never:
- Buy marks, grades, or answer keys in an assessed attempt.
- Increase leaderboard position or alter ranking.
- Bypass moderation.
- Unlock a separately sold question bank.
- Convert subscription access into an unlimited-AI promise.

Solving questions already covered by a purchased question bank does not consume ChapterCoins. Optional AI explanation, answer evaluation, or extra generation may consume an eligible allowance or coins.

## 5. Earning coins

Potential earning actions documented in the product specification:
- Completing a daily goal.
- Maintaining a verified streak.
- Completing a weekly quiz.
- Revising mistakes.
- Receiving an accepted helpful-answer mark.

Earned-coin limits should prevent farming, bot activity, and low-quality community spam. Rewards must be tied to verified, meaningful activity.

## 6. Spending coins

The student feature specification contains suggested charges for additional AI chat, generated MCQs, image scans, CQ generation, CQ answer evaluation, topic visualization, and custom model-test generation.

These are proposals, not immutable production prices. Keep charges configurable and versioned. Show the expected charge before a student confirms a coin-consuming action.

## 7. Daily task protection

A personalized daily task must remain completable without forcing a coin purchase.

Before assigning an AI-heavy task:
1. Check the student's remaining plan quota.
2. Check whether another approved allowance applies.
3. If the action is unavailable, offer a non-paid alternative.
4. Do not silently debit coins or start a paid job.

## 8. Transaction integrity

All authoritative balance and entitlement changes must happen on trusted server infrastructure.

Requirements:
- Atomic debit/credit and quota consumption.
- Idempotency for retries and duplicate requests.
- Auditable transaction and usage ledger.
- Server-side purchase/receipt verification.
- Duplicate/replayed webhook handling.
- Explicit refund and cancellation policy.
- Defined reservation and failure behavior for paid AI jobs.
- Trusted verification of rewarded-ad completion.

A mutable balance field alone is not a sufficient financial record.

## 9. Expiry and refunds

The feature specification proposes that paid coins do not expire. Do not silently introduce expiry. Earned-coin policy may be adjusted for abuse prevention, but the exact policy requires approval.

Refund, chargeback, subscription cancellation, coin reversal, and failed-job behavior must be specified before launch.

## 10. Open business decisions

- Final Free/Plus quotas and entitlement matrix.
- Subscription prices, billing periods, and founding-student discount.
- Purchase provider and mobile-store compliance.
- ChapterCoin package prices and exact action charges.
- Earned-coin caps and anti-abuse rules.
- Paid coin expiry, refunds, and chargeback handling.
- Rewarded-ad provider and verification.
- Tax, legal, and financial operations.
