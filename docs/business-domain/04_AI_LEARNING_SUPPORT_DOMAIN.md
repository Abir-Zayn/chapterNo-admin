# 04 — AI Learning Support Domain

## 1. Purpose

The AI Learning Support domain provides contextual tutoring and AI-assisted learning tasks. AI should support the student's learning journey rather than replace curriculum structure, trusted content, or human judgement.

## 2. Core capabilities

- Study-focused AI chat.
- Topic explanations, examples, follow-up questions, and step-by-step help.
- Topic-based MCQ generation.
- CQ generation.
- Supported question and answer-sheet image scanning.
- CQ answer-sheet evaluation with estimated marks and feedback.
- Short topic visualization using an AI-created script and scene plan.

The existence of a proposed capability does not prove that the selected model/provider supports it. Text generation, image understanding/OCR, and video generation are distinct capabilities and must be validated separately.

## 3. Core concepts

### AI learning request
A student's request for an AI-supported task, including the task type and the minimum context needed to complete it.

### Learning context
Relevant subject, chapter, topic, question, previous learning state, or approved source material supplied to improve the answer.

### AI job
A trackable unit of asynchronous or synchronous work, such as image processing, CQ evaluation, or visualization generation.

### AI response
The model/provider output after validation and safety checks. It may be incomplete, uncertain, malformed, or unavailable and must be handled accordingly.

### Usage allowance
The plan quota or other approved allowance that determines whether a student may perform an AI-heavy action.

## 4. Request lifecycle

1. Authenticate the student and validate ownership.
2. Identify the requested task and required capabilities.
3. Check plan entitlement, quota, and applicable coin policy.
4. Gather only necessary learning context and approved source material.
5. Send the request through a server-side provider integration.
6. Validate output structure, content, and task-specific constraints.
7. Persist only appropriate history and usage metadata.
8. Return a clear result or recoverable error to the student.

For billable or coin-consuming jobs, define reservation, cancellation, failure, retry, and refund behavior before enabling charges.

## 5. Educational quality rules

- Ground curriculum-specific answers in approved, rights-cleared educational sources where available.
- Prefer retrieval and curated content before assuming model fine-tuning is required.
- Do not represent generated questions as official board questions without evidence.
- Validate structured output and handle uncertainty honestly.
- Explain reasoning in student-friendly language.
- Do not reveal correct answers before the allowed point in ranked or assessed activities.
- CQ marks must be described as estimates, not official results.
- Preserve content provenance where it affects trust or correctness.

## 6. Privacy and security

- Keep provider API credentials on trusted server infrastructure.
- Do not send unnecessary student identifiers, unrelated uploads, or private history to a model.
- Private AI conversations and submitted answer sheets are not public by default.
- Validate upload type, size, ownership, and access.
- Treat uploaded/retrieved text as untrusted data; prompt injection must not alter system rules, permissions, or balances.
- Apply request/output limits, timeouts, bounded retries, rate limits, and per-user spend controls.
- Avoid logging private learning content by default. Prefer privacy-safe aggregate latency, error, and cost measurements.
- Do not use model output as authority to change grades, rank, entitlements, or coin balances.

## 7. Provider selection and operational quality

The project has discussed a paid DeepSeek Flash direction, but exact model identifiers and suitability must be checked against current provider documentation before integration.

Evaluate providers for:
- Bangla comprehension and generation quality.
- Mathematical reasoning and notation.
- OCR/vision capability for relevant image tasks.
- Structured-output reliability.
- Latency and throughput.
- Cost per successful task.
- Availability, rate limits, and data handling terms.

Do not assume a text-only model can perform OCR or generate video. A short topic visualization may require a multi-stage pipeline involving script generation, scene planning, visual assets, and rendering.

## 8. Fair use and fallback

- No unlimited-AI claim.
- AI tasks remain subject to configured daily/monthly quotas, technical limits, and abuse prevention.
- Quota exhaustion should block only the relevant AI-heavy action.
- Offer an available alternative such as board MCQ revision, a prepared lesson, a static explanation, or manual question selection.
- Keep provider costs observable and controlled.

## 9. Unresolved decisions

- Final provider and exact model versions.
- OCR/vision and video-generation providers or pipeline.
- Prompt, retrieval, and content validation strategy.
- AI history retention and deletion policy.
- Per-task quotas, coin charges, retry/refund rules, and spend ceilings.
