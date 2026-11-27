# 06 — Community and Leaderboard Domain

## 1. Purpose

This domain enables students to learn with and from one another through public learning discussions, shared practice activity, and optional competition.

Community participation should improve learning and belonging without exposing private student information or rewarding spam.

## 2. Core concepts

### Community post
A student-created question or learning discussion visible to the permitted audience.

### Answer
A response to a community post. The current student feature baseline includes Q&A and answers; the exact reply/thread model should follow the approved UI and product scope.

### Reaction
A lightweight response to a post or answer. Reaction types and eligibility require product definition.

### Report
A user-submitted safety or quality report against content or an account.

### Moderation action
A reviewed action to limit, remove, or otherwise handle content that violates community rules.

### Shared quiz participation
An eligible practice/quiz result that a student chooses to share with the community. Sharing must be an explicit user action.

### Leaderboard
An optional ranking view based on valid learning performance and participation signals.

## 3. Community capabilities

- Post questions and learning discussions.
- Answer other students' questions.
- React to community content.
- Report harmful, abusive, copied, or spam content.
- Share eligible quiz participation.
- Browse content with supported subject filters.
- Apply moderation and abuse-prevention controls.

Subscription status must not grant moderation authority or special ranking privileges.

## 4. Privacy rules

- Community participation and leaderboard participation should be optional where applicable.
- Students may use a username rather than a real name.
- Private AI conversations and submitted answer sheets are not published by default.
- Only explicitly selected, eligible content should be shared.
- Avoid exposing unnecessary student identity or learning history.
- Treat users as potentially underage and design moderation/reporting accordingly.

## 5. Leaderboard principles

Ranking should consider:
- Accuracy.
- Question difficulty.
- Consistency.
- Improvement.
- Valid participation.

Do not rank solely by raw activity volume. Spam, copied answers, abusive content, and manipulated quiz activity must not count.

Coins cannot increase scores, change answers, or purchase leaderboard position. Subscription does not buy rank.

## 6. Abuse prevention and moderation

Before public release, define:
- Community rules and prohibited content.
- Report categories and report handling.
- Moderation workflow and escalation.
- Spam, bot, copied-answer, and manipulation detection.
- Rate limits and posting eligibility.
- Appeals or correction process where appropriate.
- Retention and deletion behavior for reported content.

Do not launch a public community with reporting and moderation treated as optional polish.

## 7. Ranking integrity

- Ranking inputs must come from trusted assessment records.
- Validate that attempts are eligible and not duplicated or manipulated.
- Keep ranking parameters configurable and versioned.
- Define ranking periods, tie-breakers, disqualification, and recalculation behavior.
- Do not allow client-side score or rank updates to become authoritative.

## 8. Current scope boundaries

The student feature specification includes global community Q&A, answering, reactions, reporting, moderation, quiz sharing, and opt-in leaderboard participation.

Group chat, teacher participation, broader note-sharing, and institution-specific communities have been discussed but require separate scope approval. The current feature specification excludes school/coaching groups and institution reports.
