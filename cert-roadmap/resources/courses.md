# Courses & Learning Resources

Courses available for the HashiCorp Certified Terraform Associate (004) preparation.

---

## Your Enrolled Courses

### 1. Terraform Essentials — LinuxTips

| Detail | Info |
|--------|------|
| Platform | LinuxTips |
| URL | https://school.linuxtips.io/path-player?courseid=terraform-essentials |
| Language | Portuguese |
| Focus | Core Terraform concepts, hands-on labs |

**Best for:**
- Objective 1: IaC Concepts
- Objective 3: Core Workflow
- Objective 4: Configuration Language (HCL)

**Study approach:**
- Follow along with the hands-on labs
- Pause and replicate each demo in `/home/triplom/terraform-cert-work/local/`
- Use `terraform console` to experiment with functions shown in the course

---

### 2. Learning Terraform — LinkedIn Learning

| Detail | Info |
|--------|------|
| Platform | LinkedIn Learning |
| URL | https://www.linkedin.com/learning/learning-terraform-15575129 |
| Language | English |
| Focus | Terraform fundamentals, workflow, modules |

**Best for:**
- Objective 2: Terraform Fundamentals (providers, state, lock file)
- Objective 5: Modules
- Objective 6: State Management

**Study approach:**
- Watch each section, then check understanding against the exam objectives in `cert-roadmap/exam-objectives/`
- Pay attention to remote backends (Objective 6) and the dependency lock file (Objective 2)

---

### 3. HashiCorp Certified Terraform Associate (50 Demos) — Udemy (StackSimplify)

| Detail | Info |
|--------|------|
| Platform | Udemy |
| Instructor | StackSimplify (Kalyan Reddy) |
| URL | https://www.udemy.com/course/terraformcertified/ |
| Language | English |
| Content | 50 hands-on demos covering all exam objectives |
| Note | Originally 003 content — ~95% still applies to 004 |

**Best for:** All 8 objectives — the most exam-focused of the three courses.

**Demo-to-Objective mapping:**

| Demos | Topic | Objective |
|-------|-------|-----------|
| 01–05 | Terraform basics, init, plan, apply | Obj 1, 3 |
| 06–10 | Variables, outputs, data sources | Obj 4 |
| 11–15 | Providers, versions, lock file | Obj 2 |
| 16–20 | State management, backends | Obj 6 |
| 21–25 | Modules (local + registry) | Obj 5 |
| 26–30 | Lifecycle, meta-arguments | Obj 4 |
| 31–35 | Workspaces, remote state | Obj 6 |
| 36–40 | Import, state commands | Obj 7 |
| 41–45 | HCP Terraform, VCS workflow | Obj 8 |
| 46–50 | Sentinel, policies, drift detection | Obj 8 |

**004 vs 003 differences to watch:**
- `moved` block (1.1+) — new in 004
- `removed` block (1.7+) — new in 004
- Import blocks (1.5+) — new in 004
- `apply -refresh-only` replacing `terraform refresh`
- `apply -replace` replacing `terraform taint`
- HCP Terraform terminology (was "Terraform Cloud" in 003)
- Terraform 1.12 as the tested version

**Study approach:**
- Work through all 50 demos sequentially
- Replicate each demo in the `local/` directory when possible (Docker, no cloud needed)
- For AWS/Azure demos, trace through the code even if you don't run them

---

## Suggested Study Schedule (Using All 3 Courses)

| Week | Primary | Secondary |
|------|---------|-----------|
| 1 | LinkedIn Learning (full course) | LinuxTips sections 1-3 |
| 2 | Udemy demos 1-25 | LinuxTips remaining |
| 3 | Udemy demos 26-50 | Review exam-objectives/ |
| 4 | Practice tests + cheatsheets | Weak areas only |
| Week 5+ | Full practice exams | exam-tips.md review |

---

## Repo as Lab Environment

The `learning-terraform` repo itself serves as your lab:

```
local/       ← Start here (Docker, no cloud needed)
  main.tf    ← Docker containers (Tomcat + MinIO)

kubernetes/  ← Module examples (Objective 5)
  modules/
    webapp/  ← Child module hands-on
    storage/ ← Second child module

aws/         ← If you have AWS credentials
azure/       ← If you have Azure credentials
```

**Minimal setup (no cloud account needed):**
1. Ensure Docker is running
2. Work from `/home/triplom/terraform-cert-work/local/`
3. Run through all commands in `03-core-workflow.md`

---

*See also: [Official Resources](./official.md) | [Practice Tests](./practice-tests.md)*
