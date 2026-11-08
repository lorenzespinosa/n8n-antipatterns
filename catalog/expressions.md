# Expressions

Recurring mistakes in n8n expressions, dates, and Code node usage.

## Entries

### EXPR-1: Cross-branch references return undefined

**Symptom:** An expression reads `$json.field` but the field was set on a different branch. The value comes out "undefined" and the request built from it breaks. No error points at the cause.

**Why it hurts:** `$json` points at the current node's input only. Fields produced on another path are not there. Branching with IF or Loop Over Items hides this until the output is wrong somewhere far downstream.

**Fix:** Bring the node that produces the value into the same branch, or Merge the branches first so both values reach the next node. To read a specific node anywhere in the run, reference it by name with `$('Node Name').first().json.field`.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/nodes-parameters-url-https-newsapi-org-v2-everything-apikey-setup1-first-json-apikey-q-json-output-clean-company-name-from-datetime-now-minus-days-setup1-first-json-newsage-tof/258049
- https://docs.n8n.io/code/cookbook/luxon/
  Timezone resolution order: the workflow timezone setting, else the instance
  GENERIC_TIMEZONE, else the default; vanilla Date ignores both.

### EXPR-2: Legacy expression syntax copied from old tutorials

**Symptom:** Workflows carry `$items()`, `$node["Name"].json`, and `$item("0")` forms. Some break after upgrades; others behave oddly with multiple items.

**Why it hurts:** These forms predate the current syntax. Old forum answers and old templates still circulate them, so they spread into new work. The current forms are the `$('Node Name')` proxy and the `$input` methods, which the expression reference documents.

**Fix:** Use `$('Node Name')` for node references and `$input.all()`, `$input.first()`, or `$input.item` for input data. When something copied from an old thread misbehaves, check the expression reference first before debugging the node.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/nodes-parameters-url-https-newsapi-org-v2-everything-apikey-setup1-first-json-apikey-q-json-output-clean-company-name-from-datetime-now-minus-days-setup1-first-json-newsage-tof/258049
- https://docs.n8n.io/build/work-with-data/transform-data/expression-reference/nodeinputdata
- https://docs.n8n.io/build/code-in-n8n/use-built-in-shortcuts

### EXPR-3: Two clocks: the schedule runs in one zone, the code in another

**Symptom:** A schedule fires at the wrong hour after a deploy. Date fields shift by hours between environments. The executions list shows the time you set, but the effect lands elsewhere.

**Why it hurts:** The Schedule Trigger follows the workflow timezone, else the instance timezone, which defaults to America/New_York on self-hosted instances when unset. JavaScript date code follows the process time zone. Setting one without the other leaves the two apart, and the mismatch only shows in production.

**Fix:** Set the timezone explicitly on each workflow, which is the surgical fix when one instance serves several zones. On self-hosted, set both `GENERIC_TIMEZONE` and `TZ` to the same value. Prefer `$now` and the built-in date methods over raw JavaScript `Date`. `$now` follows the workflow timezone when one is set in workflow settings, and falls back to the instance timezone otherwise, while a raw `Date` follows the process time zone and ignores both.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/my-9-am-workflow-fired-at-1-am-the-schedule-trigger-timezone-gotcha-and-the-fix/322339
- https://community.n8n.io/t/n8n-output-timezone-mismatch-with-expression-and-cron-timezone/13374
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger

### EXPR-4: Code node mode mismatch

**Symptom:** A Code node hangs on trivial code or returns the wrong shape. Code that ran for months stops after an upgrade.

**Why it hurts:** Run Once for All Items expects the code to return an array; Run Once for Each Item expects one object per run. The wrong mode makes correct code look broken. Separately, old Function nodes are deprecated: they do not use task runners and stop receiving fixes, and version 3.0 retires them in favor of the Code node.

**Fix:** Check the mode toggle matches the return shape before debugging the code. Replace Function nodes with Code nodes and update the data references. If a Code node gets stuck after an upgrade, copying the code into a fresh node has cleared it for users.

**Caught by lint:** `BP-02` (deprecated Function node)

**Sources:**
- https://community.n8n.io/t/help-code-node-stopped-working/90586
- https://blog.n8n.io/introducing-n8n-v3/
