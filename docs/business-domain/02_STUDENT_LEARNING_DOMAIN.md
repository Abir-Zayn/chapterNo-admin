# 02 — Student Learning Domain

## 1. Purpose

The Student Learning domain manages the learner's ongoing study journey: what the student should study, what they have completed, where they struggle, and what they should revise next.

Its goal is to turn isolated practice sessions into a continuous, personalized learning process.

## 2. Core concepts

### Student
The authenticated learner who owns their private learning data, preferences, history, and progress.

### Learning profile
A structured view of the student's curriculum context and learning preferences. Exact profile fields and required identity data should be minimized and approved separately.

### Subject and chapter
Curriculum structures used to organize lessons, questions, practice, progress, and revision. Content must carry appropriate curriculum/board provenance.

### Daily learning guide
A prioritized set of suggested learning activities for a particular day. It can include practice, revision, a prepared lesson, or another supported task.

### Study routine
A learner-defined schedule or recurring plan for study, quizzes, revision, or exam preparation.

### Learning activity
A meaningful event such as completing a quiz, practising a topic, reviewing a mistake, or finishing a study task.

### Learning progress
A derived view of a learner's performance and consistency across subjects, chapters, and topics.

### Mistake Notebook
A collection of questions or concepts the student answered incorrectly or chose to save for later revision, with explanations and re-practice support.

## 3. Main capabilities

- Personalized daily recommendations and reminders.
- Calendar for study routines, quizzes, revision, and exam preparation.
- Daily check-in and contribution-style activity graph.
- Streak tracking and missed-day recovery tasks.
- Diagnostic assessment and weak-topic detection.
- Topic mastery and progress analytics.
- Mistake Notebook with saved errors, explanations, and re-practice.
- Personalized revision recommendations based on recent performance.

## 4. Typical learning journey

1. The student opens Home.
2. ChapterNo presents the most relevant next activity or a Start Learning state for a new learner.
3. The student starts a lesson, quiz, or revision activity.
4. The activity records its result and relevant learning signals.
5. The system updates progress and identifies possible weaknesses.
6. The student receives a practical next step, such as revisiting a topic or retrying saved mistakes.

The Home screen should prioritize continuing the latest resumable activity when one exists. Do not fabricate past activity for a new user.

## 5. Progress and analytics

Potential progress measures include:
- Questions attempted and solved.
- Accuracy and score.
- Streak and study consistency.
- Subject, chapter, and topic mastery.
- Weak-topic indicators.
- Revision and mistake re-practice history.
- Improvement over time.

Metrics must be interpreted carefully. A high number of clicks or attempted questions is not necessarily evidence of learning. Analytics should explain meaningful progress rather than reward activity volume alone.

## 6. Business rules and constraints

- Student-owned records must be private by default.
- A student must not access another student's private learning history.
- Daily tasks should remain achievable without requiring a coin purchase.
- When an AI-heavy task is unavailable because of quota exhaustion, provide a non-paid alternative where possible.
- Progress calculations must be consistent and testable.
- Ranked or timed assessment resumption requires explicit rules; ordinary practice should save and restore progress where supported.
- Streak and reward calculations need server-authoritative time and anti-abuse controls.

## 7. Free and Plus direction

The student specification describes:
- Free: basic daily recommendations, limited routines, a limited recent mistake history, and basic score/accuracy/streak analytics.
- Plus: adaptive daily plans, more routines, deeper weak-topic and mastery insights, broader revision support, and richer history.

The exact limits in the feature specification are proposals until confirmed for production. Keep entitlements configurable rather than scattering numeric limits through the application.

## 8. Out of scope or unresolved

- Foundation/Standard learning-mode selector is excluded from the current student feature baseline.
- Parental-control behavior is not finalized.
- School/coaching group assignments and institution reports are outside the current student tier specification.
- Exact learning-profile fields, curriculum coverage, and adaptive recommendation algorithm require separate specification.
