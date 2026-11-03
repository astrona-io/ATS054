# Reusable Question Banks

`assessments/index.yaml` lists the banks in teaching order. Each bank uses schema version 1 and the contract in `schemas/question-bank.schema.json`. This is an authoring format, not an existing Astrona quiz API.

## Banks

- `sections/section-0X0/quiz.yaml`: one knowledge check for each section, with 8 original single-choice questions. The course manifest lists it as a `type: quiz` entry with `pass_score: 70` after the capstone lab.
- `sections/final-domain-quiz.yaml`: the final domain quiz, with 15 questions (3 for each section).

Questions have stable IDs, one correct option, per-option feedback, a measurable learning objective and source reading paths for author traceability. Banks stay draft for review.

## Fields

- `id`: stable bank or question identity.
- `scope`: section or domain checkpoint.
- `learning_objective`: the measurable outcome checked by the question.
- `source_readings`: author traceability, not learner navigation.
- `options`: stable option IDs, answer text and per-option feedback.
- `correct_option`: the ID of the single correct option.

The banks contain answer keys and are public learning material. Do not treat scores as an official CCA result.
