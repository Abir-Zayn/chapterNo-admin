# 01 — ChapterNo Business Overview

## 1. Product identity

ChapterNo is a Bangladesh-first mobile learning companion, initially designed for secondary-school students preparing for SSC examinations. It combines curriculum-aware study workflows, practice, feedback, revision, and progress tracking.

It is not intended to be merely another general-purpose AI chat application or a static question bank. Its differentiation is the persistent student context and the complete learning loop:

**Plan → Learn → Practise → Identify mistakes → Revise → Measure improvement.**

## 2. Target users and environment

### Primary users
- Bengali-speaking SSC students in Bangladesh.
- Learners who need structured daily study guidance and exam-oriented practice.
- Students who benefit from clear Bangla explanations and feedback.

### Usage environment
- Android-first mobile experience, built with Flutter; iOS readiness is also a goal.
- Budget and midrange Android devices must be supported.
- Intermittent or expensive mobile data is a normal design constraint.
- Bangla (Bangladesh) is the primary learner-facing language; English is secondary.

### Potential ecosystem participants
- Teachers and content contributors.
- Coaching centres and schools as possible distribution/content partners.
- Parents or guardians may become relevant to future safety and progress features, but parental-control behavior is not finalized.

## 3. Product value

ChapterNo should help a student:
1. Know what to study today.
2. Start a lesson or practice session without friction.
3. Practise curriculum-relevant questions.
4. Understand mistakes and receive useful feedback.
5. Revisit weak topics.
6. See measurable progress over time.

The product should optimize for meaningful learning progress rather than chat volume, screen time, notification count, or artificial engagement.

## 4. Core product capabilities

- Personalized daily learning guide and reminders.
- Study calendar, routines, daily check-in, and streak.
- Topic and board-based MCQ practice.
- Board CQ practice, initially question parts 1 and 2.
- Chapter tests and model tests.
- AI tutoring and structured explanations.
- CQ generation and answer-sheet photo submission with estimated AI feedback.
- Mistake Notebook, bookmarks, weak-topic detection, and revision recommendations.
- Learning analytics and activity history.
- Community Q&A and optional leaderboard participation.
- Separately purchased or assigned teacher question-bank entitlements.

A feature appearing in this list does not mean it is already implemented or scheduled for the current MVP.

## 5. Business model

Potential revenue streams documented for consideration:
1. **Student subscriptions:** Free and Plus are the baseline plan names.
2. **ChapterCoin purchases:** optional utility balance for eligible usage beyond included quotas.
3. **Advertising:** including possible rewarded ads, subject to product, legal, and platform requirements.
4. **Teacher question banks:** separately sold content entitlements.
5. **School/coaching partnerships:** possible distribution, referral, content, or revenue-share arrangements.

Pricing, payment provider, commissions, advertising placement, tax/legal setup, and launch purchase flows remain decisions for the project owner. A monthly price around BDT 350 was discussed historically but is not a final price and must not be hard-coded from this document.

## 6. Initial market plan

The initial field focus discussed was Halishahar, Chittagong:
- A pilot outreach target of approximately five coaching centres and two schools.
- An initial cohort target of approximately 100 students.
- A later growth target of 500 students.

These are planning targets, not existing users, traction, signed partnerships, or guaranteed outcomes. Demo data and prototype capabilities must be labelled honestly.

## 7. Product principles

- Free users must receive a meaningful learning experience.
- Plus expands supported access and fair-use allowances; never promise unlimited AI.
- Learning outcomes and content quality take priority over engagement tricks.
- Private AI conversations and submitted answer sheets are private by default.
- Student privacy and age-appropriate safety are first-class requirements.
- Paid features must not create pay-to-win grades, answers, moderation privileges, or leaderboard position.
- Quota exhaustion for an AI-heavy action must not block unrelated learning access.
- The system should offer a non-paid alternative when an AI-dependent daily task cannot be completed.

## 8. Scope boundaries

The current student feature baseline does not include:
- Foundation/Standard learning-mode selector.
- School/coaching group modules, institution reports, premium assignments, or partner-content modules.
- Finalized parental controls.
- A finalized institutional/admin product.

These may be revisited through explicit product decisions. Do not silently add them to the current student scope.

## 9. Success measures

Potential product metrics (to be defined carefully and collected with appropriate privacy safeguards):
- Weekly active learners and returning learner rate.
- Practice completion and question accuracy.
- Improvement in weak-topic mastery.
- Revision completion and mistake re-practice.
- Study-plan completion consistency.
- AI response quality, latency, failure rate, and cost per successful task.
- Subscription conversion and retention.

Do not optimize a metric in a way that undermines genuine learning or student wellbeing.
