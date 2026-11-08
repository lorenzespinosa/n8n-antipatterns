# Workflow structure and naming

Recurring mistakes in how workflows are shaped, named, and documented on the canvas.

## Entries

### STR-1: One canvas does everything

**Symptom:** A workflow grows past 50 nodes. Every fix risks the whole run, and slow branches hold up the rest.

**Why it hurts:** Everything shares one execution, one memory space, and one retry scope. An error in one path can cost the whole run, and nobody can review a canvas that size.

**Fix:** Split by job into sub-workflows. Keep triggers thin: let the trigger capture the data and hand work to a sub-workflow that owns its own retry logic, since a trigger node cannot be looped back into. The docs describe calling workflows from workflows and converting a selection of nodes into a sub-workflow.

**Caught by lint:** `BP-06` (warns on workflows above 50 nodes)

**Sources:**
- https://docs.n8n.io/build/flow-logic/break-workflows-into-smaller-parts
- https://community.n8n.io/t/what-is-the-best-pattern-for-triggering-n-sub-workflows-in-parallel-and-resuming-main-workflow-when-all-complete/233446
- https://community.n8n.io/t/every-node-retry-on-fail-max-5000ms-why/273374
- https://community.n8n.io/t/some-problems-with-splitinbatches/19788

### STR-2: No notes on the canvas

**Symptom:** Nobody new can tell what a workflow does, what it needs, or where to be careful. Template reviewers reject submissions over note quality.

**Why it hurts:** Node names alone do not carry intent, setup steps, or the credentials a workflow expects. Handover, review, and incident response all stall without that context. One creator reported a template rejected three times over sticky note quality before it passed.

**Fix:** Add one overview note that says what the workflow does and how to set it up. Add short section notes over each group of nodes. Use single warning notes sparingly on dangerous nodes. The public template guidelines are stricter than most team norms; use them as a floor, not a ceiling.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/workflow-template-rejected-3-times-need-guidance-on-sticky-note-requirements/324146
- https://docs.n8n.io/build/understand-workflows/workflow-components/add-notes-and-documentation
- https://docs.n8n.io/contribute/create-templates/sticky-note-guidelines

### STR-3: Renamed nodes break expressions

**Symptom:** Renaming a node turns values downstream into "undefined". Two nodes with the same name make references resolve to the wrong one.

**Why it hurts:** Expressions reference nodes by name. A rename cuts the link; a duplicate name makes the reference ambiguous. The failure is silent: the expression returns nothing rather than erroring.

**Fix:** Name each node for its job before wiring expressions into it. Before any rename, search the workflow for references to the old name. Keep node names unique.

**Caught by lint:** `BP-04` (duplicate node names in one workflow)

**Sources:**
- https://community.n8n.io/t/nodes-parameters-url-https-newsapi-org-v2-everything-apikey-setup1-first-json-apikey-q-json-output-clean-company-name-from-datetime-now-minus-days-setup1-first-json-newsage-tof/258049

### STR-4: Merge expected to wait for async branches

**Symptom:** Merge output arrives early or partial. Data from one branch repeats while the last items from another drop.

**Why it hurts:** Merge combines branches inside one execution. It cannot wait on separately triggered workflows or webhooks that arrive over time, so a fan-out that expected collection instead loses or duplicates data. Merge also only runs a source node again when it receives new input on that path.

**Fix:** For fan-out over sub-workflows, call them without waiting, pause the parent on a Wait node set to resume on webhook, and have each sub-workflow call back when done. Track completions with a counter and resume the parent when the count matches. Inside one execution, make sure every branch feeding a Merge gets fresh input on each pass.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/what-is-the-best-pattern-for-triggering-n-sub-workflows-in-parallel-and-resuming-main-workflow-when-all-complete/233446
- https://community.n8n.io/t/some-problems-with-splitinbatches/19788
