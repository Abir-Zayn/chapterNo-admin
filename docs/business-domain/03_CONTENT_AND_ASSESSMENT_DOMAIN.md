# 03 — Content and Assessment Domain

## 1. Purpose

This domain manages educational content and the assessment lifecycle: curriculum organization, question provenance, practice sessions, answer submission, scoring, feedback, and saved results.

## 2. Core concepts

### Curriculum
The structured syllabus context used to organize educational content. It may include education level, board, subject, chapter, and topic. The exact supported curriculum catalogue must be maintained as a controlled source of truth.

### Educational content item
A lesson, explanation, question, answer key, or other learning resource. It should have a source/provenance record and appropriate usage rights.

### Question
A structured assessment item. Depending on type, it may contain a prompt, options, expected answer, marking guidance, explanation, difficulty, topic mapping, and source metadata.

### MCQ
A multiple-choice question with a defined set of options and an answer key. Correct answers must not be exposed before the permitted reveal point in an assessed attempt.

### CQ
A creative/descriptive question. The initial board CQ practice scope discussed covers question parts 1 and 2. CQ evaluation may use a rubric or marking guide and should return transparent, appropriately qualified feedback.

### Practice session
A learner's attempt to answer a set of questions. It records the relevant question versions, answers, timing where applicable, and outcome.

### Assessment result
A record of score, correctness, feedback, and other supported outcome details for a completed attempt.

### Question-bank entitlement
A permission to access a separately purchased or assigned set of questions. It is distinct from a subscription entitlement.

## 3. Supported assessment experiences

- Topic-based MCQ generation and answering.
- Board MCQ practice with answer review.
- Board CQ practice, initially parts 1 and 2.
- Chapter tests and model tests.
- Timed assessment where explicitly supported.
- CQ generation.
- Answer-sheet image submission and AI-assisted feedback.
- Assessment history and answer review.
- Bookmarks and saved questions.
- Separately purchased or assigned teacher question banks.

## 4. Assessment lifecycle

A typical attempt follows:

1. Select an eligible practice or assessment activity.
2. Resolve access rights and applicable usage allowance.
3. Load a stable question set/version.
4. Capture answers and prevent accidental duplicate submission.
5. Evaluate using the applicable answer key or rubric.
6. Persist the result and update relevant learning signals.
7. Present review, explanation, and next-step recommendations.

A retry must not accidentally create duplicate submissions, duplicate charges, or multiple rewards.

## 5. Content quality and provenance

- Preserve source, board, year, subject, chapter, topic, and rights information where applicable.
- Do not label generated content as an official board question.
- Do not label a solution as verified unless it has been verified.
- Keep generated content distinguishable from curated or official-source content.
- Validate answer keys and explanations before presenting them as authoritative.
- Support corrections and versioning for content that changes.

## 6. CQ answer-sheet evaluation

The intended flow:
1. Student selects or captures an answer-sheet image.
2. The system validates file type, size, image quality, and access.
3. An AI processing job extracts and evaluates the answer against an appropriate rubric.
4. The result provides strengths, mistakes, likely marks, and actionable improvements.
5. The student can review the result and continue learning.

The result must clearly state:

> AI-এর মূল্যায়ন আনুমানিক; শিক্ষক বা বোর্ডের চূড়ান্ত নম্বর নয়।

AI-generated marks are estimates, not official grades. Do not communicate false precision or guarantee examiner-level accuracy.

## 7. Question banks

- A purchased or assigned question bank is a separate content entitlement.
- A Plus subscription does not automatically include every separately sold bank.
- Solving questions already covered by a purchased bank does not consume ChapterCoins.
- Optional AI explanation, evaluation, or additional generation may consume eligible quota or coins.
- Access must be checked server-side for the relevant student and content entitlement.

## 8. Assessment integrity

- Do not reveal answers prematurely during ranked or assessed attempts.
- Prevent duplicate submissions and replay abuse.
- Validate question IDs, answer payloads, attempt ownership, and assessment status on trusted infrastructure.
- Keep marks and authoritative outcomes server-controlled.
- Ranking must not be manipulable through coins or subscription status.
- Define timer, pause, resume, retry, and late-submission behavior before implementing high-stakes or ranked flows.

## 9. Open decisions

- Exact curriculum and board coverage.
- Rights and licensing for source question banks.
- Marking rubrics and human review process for CQ.
- Ranked quiz rules, including the previously discussed maximum of five attempts per day.
- Timer and resumption behavior for each assessment type.
- Final production quotas and question-bank purchase flow.
