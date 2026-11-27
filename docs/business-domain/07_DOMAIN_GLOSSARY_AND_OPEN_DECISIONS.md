# 07 — Domain Glossary and Open Decisions

## 1. Shared glossary

| Term | Meaning |
|---|---|
| Student | Authenticated learner who owns private learning data. |
| Learning profile | Student's approved learning and curriculum context. |
| Subject / Chapter / Topic | Curriculum hierarchy for organizing content and progress. |
| Daily learning guide | Prioritized study activities suggested for a day. |
| Study routine | Student-defined schedule for study or revision. |
| Learning activity | Meaningful event such as quiz completion or mistake review. |
| Mistake Notebook | Saved incorrect or review-worthy questions for later revision. |
| Question | Structured educational assessment item with provenance. |
| MCQ | Multiple-choice question with options and answer key. |
| CQ | Creative/descriptive question evaluated against a marking guide. |
| Practice session | A student's attempt at a question set. |
| Assessment result | Persisted score, answers, and supported feedback. |
| Question-bank entitlement | Separate access permission for a purchased or assigned question bank. |
| Plan | Free or Plus access package. |
| Entitlement | Permission to use a feature or content. |
| Quota | Bounded allowance over a defined time window. |
| ChapterCoin | Utility balance for optional eligible usage beyond included allowances. |
| AI job | Trackable unit of AI processing, possibly asynchronous. |
| Community post | Student-created learning discussion or question. |
| Leaderboard | Optional ranking based on valid learning performance. |

## 2. High-level domain relationships

- A **Student** owns a learning profile, routines, learning activities, practice sessions, assessment results, saved mistakes, and private AI history.
- A **Subject** contains chapters; chapters contain topics and link to approved learning content and questions.
- A **Practice Session** uses a versioned question set and produces an **Assessment Result**.
- An **Assessment Result** may update learning progress, weak-topic signals, revision recommendations, and eligible leaderboard inputs.
- A **Plan** grants feature entitlements and quotas to a student.
- A **Question-Bank Entitlement** independently grants access to a specific content collection.
- A **ChapterCoin Transaction** records a credit or debit and must be auditable.
- An **AI Job** may consume a quota or coins according to an approved policy.
- A **Community Post** may receive answers, reactions, and reports.
- A **Leaderboard** consumes validated assessment signals, not client-submitted rank values.

These are conceptual relationships, not a finalized database schema or API contract.

## 3. Decision status vocabulary

- **Baseline:** documented product direction to preserve unless the owner changes it.
- **Proposed:** documented suggestion that still needs approval.
- **Discussed:** considered in conversation but not approved for implementation.
- **Unresolved:** requires a decision before dependent work.
- **Future:** outside the current student scope or planned for a later phase.

## 4. Open decisions that must not be guessed

### Product and business
- Final pricing, billing periods, founding-student discount size, and launch offer.
- Final pilot commitments and partner agreements.
- Advertising placement, rewarded-ad provider, and policy compliance.
- School/coaching partnership model and any revenue share.
- Legal, tax, business registration, and payment operations.

### Subscription and coins
- Final Free/Plus quotas and device limits.
- ChapterCoin package prices and exact action charges.
- Earned-coin caps, expiry, refunds, chargebacks, and failed-job refunds.
- Payment provider and platform purchase requirements.

### Learning and content
- Exact curriculum/board coverage and content catalogue.
- Content licensing and source-question provenance.
- Final CQ rubric and human-review approach.
- Diagnostic and adaptive recommendation algorithms.
- Ranked quiz rules, including the discussed five-attempt daily limit.
- Timer, pause, retry, and resumption rules.

### AI
- Final provider and exact model IDs.
- OCR/vision and visualization/video pipeline.
- AI history retention and deletion.
- Per-task spend limits, retry rules, and cost controls.

### Community and safety
- Moderation staffing and escalation process.
- Community rules, reporting categories, and appeals.
- Final ranking formula, periods, and tie-breakers.
- Parental-control behavior and release timing.

### Technology
- Backend architecture was not finalized in the business guide dated 12 November 2026. Supabase and Cloudflare had been considered, but that discussion is not approval.
- Inspect the current repository and latest owner decision before treating any backend, state-management, routing, or dependency choice as canonical.
- Verify provider/model capabilities and third-party platform requirements from current official documentation before implementation.

## 5. Source and authority

This pack consolidates the ChapterNo Business Context and Agent Work Policy (12 November 2026) and the ChapterNo Student Feature Specification (3 November 2026), together with later owner discussions captured in project context.

It intentionally distinguishes stable product rules from proposals and unresolved decisions. The latest explicit owner-approved decision and the current repository take precedence over this summary.
