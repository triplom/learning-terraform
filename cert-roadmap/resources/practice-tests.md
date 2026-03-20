# Practice Tests & Assessment Resources

Resources to test your knowledge before the Terraform Associate (004) exam.

---

## Official Sample Questions

| Resource | URL | Notes |
|----------|-----|-------|
| Official sample questions | https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-questions | Free, ~20 questions from HashiCorp |

> Start here — these are the closest to the actual exam format. If you score <80% on these, spend more time on the weak objectives before purchasing paid practice exams.

---

## Paid Practice Exams

| Platform | URL | Questions | Notes |
|----------|-----|-----------|-------|
| Udemy — Bryan Krausen | Search "Terraform Associate Practice Exam" | 250+ | Highly rated, frequently updated |
| Udemy — Zeal Vora | Search "Terraform Associate 004" | 200+ | Good for 004-specific content |
| ExamTopics | https://www.examtopics.com | Community-sourced | Free but varies in accuracy |
| Whizlabs | https://www.whizlabs.com | 200+ | Good explanations |

> **Recommendation:** Bryan Krausen's Udemy practice exams are widely considered the best for the Terraform Associate exam. Purchase when on sale (~$15).

---

## Free Community Resources

| Resource | URL | Notes |
|----------|-----|-------|
| GitHub: StackSimplify study guide | https://github.com/stacksimplify/hashicorp-certified-terraform-associate | Paired with Udemy course |
| r/Terraform on Reddit | https://www.reddit.com/r/Terraform/ | Community discussions, exam experiences |
| HashiCorp Community Forums | https://discuss.hashicorp.com | Official community forum |

---

## Self-Assessment by Objective

Use this checklist to identify weak areas:

### Objective 1: IaC Concepts (~7%)
- [ ] Can explain declarative vs imperative IaC
- [ ] Can describe Terraform's differentiators vs other tools (Ansible, Chef, etc.)
- [ ] Can list at least 5 benefits of IaC

### Objective 2: Terraform Fundamentals (~15%)
- [ ] Can explain provider tiers (official, partner, community)
- [ ] Can write version constraints using `~>`, `>=`, `=`
- [ ] Can explain the purpose of the lock file (`.terraform.lock.hcl`)
- [ ] Can explain what state stores and why it's needed
- [ ] Know what `terraform init` does step-by-step

### Objective 3: Core Workflow (~15%)
- [ ] Know the order: init → fmt → validate → plan → apply → destroy
- [ ] Know all plan output symbols (`+`, `-`, `~`, `-/+`)
- [ ] Know what `-auto-approve` does and when to use it
- [ ] Know what `-refresh-only` does and why `terraform refresh` is deprecated
- [ ] Know what `-replace` does and why `terraform taint` is deprecated

### Objective 4: Configuration (~22%)
- [ ] Can write variables with types, defaults, and validation
- [ ] Know variable precedence order (all 6 levels)
- [ ] Can write `count` and `for_each` resources
- [ ] Know when to use each lifecycle argument
- [ ] Know that Terraform has NO user-defined functions
- [ ] Know that `sensitive = true` doesn't encrypt state

### Objective 5: Modules (~15%)
- [ ] Know all module source types and which support `version`
- [ ] Can write a module call with input variables
- [ ] Know that module scope is isolated (data flows via inputs/outputs only)
- [ ] Know what `terraform init` does with modules

### Objective 6: State Management (~15%)
- [ ] Know the difference between local and remote backends
- [ ] Know which backends support locking
- [ ] Know what the `serial` and `lineage` fields in state mean
- [ ] Know the `moved` block syntax and when to use it vs `state mv`
- [ ] Know that `terraform_remote_state` only exposes `output` values

### Objective 7: Maintain Infrastructure (~15%) — note: weight shared with Obj 6
- [ ] Know the `terraform import` CLI syntax
- [ ] Know the import block syntax (Terraform 1.5+)
- [ ] Know all `terraform state` subcommands
- [ ] Know what `TF_LOG=TRACE` does
- [ ] Know that `state rm` does NOT destroy the real resource

### Objective 8: HCP Terraform (~11%)
- [ ] Know the difference between HCP Terraform workspaces and CLI workspaces
- [ ] Know what speculative plans are
- [ ] Know what variable sets are and how they apply
- [ ] Know Sentinel policy results: pass, soft-fail, hard-fail
- [ ] Know that drift detection doesn't auto-remediate
- [ ] Know that Sentinel requires a paid plan

---

## Scoring Your Readiness

| Practice Test Score | Action |
|---------------------|--------|
| < 60% | Review all 8 exam-objectives/ files; redo weak sections |
| 60–70% | Focus on weakest 2-3 objectives; review exam-tips.md |
| 70–80% | Near ready; review common traps in exam-tips.md |
| 80–90% | Schedule the exam; do one more full practice test day-before |
| > 90% | Book the exam and go! |

---

## Last-Week Study Plan

**Day 1:** Full practice exam (timed, 60 min) → review wrong answers

**Day 2:** Focus on the 2 lowest-scoring objectives → re-read those exam-objective files

**Day 3:** All 4 cheatsheets — read through, quiz yourself

**Day 4:** Another timed practice exam → note any NEW wrong answers

**Day 5:** exam-tips.md — the "5 Minute Pre-Exam Checklist"

**Day 6:** Light review, rest — don't cram

**Day 7 (Exam day):** Read exam-tips.md once before logging in

---

## What to Expect on Exam Day

- **Format:** ~57 multiple-choice / multiple-select questions
- **Time:** 60 minutes (about 1 minute per question)
- **Environment:** PSI proctored — webcam, microphone, clean desk required
- **Browser:** The exam is open-book (browser allowed), but no AI tools/forums
- **Passing:** ~70% (~40 correct) — score displayed immediately after

**Multiple-select tip:** The question will tell you "select 2" or "select all that apply." Read carefully — these are harder than single-select.

---

*See also: [Courses](./courses.md) | [Official Resources](./official.md)*
