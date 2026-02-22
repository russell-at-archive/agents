# Mastering Spec-Driven Design (SDD)

Welcome to the definitive guide for **Spec-Driven Design**. This curriculum is structured to take you from the high-level philosophy of "Spec-First" engineering to the physical implementation of the `.specs/` directory structure.

## Learning Path

1. **[The Macro Manifesto](./01-macro-manifesto.md)**
   - The foundational pillars of SDD: Specify, Plan, Task, and Validate.
   - Understanding the "Spec-First" mandate and the Specification as a Contract.

2. **[The Meso Workflow Lifecycle](./02-meso-workflow.md)**
   - The tactical structure of the repository's `.specs/` hierarchy.
   - Mapping the four phases of development to physical directories: `/requirements/`, `/plans/`, `/tasks/`, and `/constraints/`.

3. **[Micro Implementation Standards](./03-micro-implementation.md)**
   - Precision templates for Requirements, Plans, and Tasks.
   - The Expert Protocol for implementation, "Single Developer Turn" rules, and advanced validation patterns.

## Core Philosophy: Spec-First, Code-Second

- **Specification is the Truth**: The spec is the authoritative source of intent. If code and spec disagree, the code is incorrect.
- **No Specification, No Implementation**: No code should be written until an upstream specification has been validated and approved.
- **Outcome over Instructions**: Define *what* success looks like, allowing agents the autonomy to navigate the *how*.
- **Traceability is Quality**: Every surgical code change must be traceable back to an atomic task, a technical plan, and a requirement.

## How to Use These Documents

- **Read Sequentially**: Don't skip to templates before understanding the philosophy and the directory hierarchy.
- **Reference as a Constitution**: Keep these documents open during your development lifecycle as the definitive standard for your work.
- **Apply Immediately**: Start by creating a `.specs/` directory in your project and documenting your next feature using the templates in `03-micro`.
