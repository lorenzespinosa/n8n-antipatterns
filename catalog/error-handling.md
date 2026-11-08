# Error handling

Recurring mistakes in how n8n workflows fail, retry, and alert.

## Entries

### ERR-1: No error workflow set

**Symptom:** A workflow fails overnight. Nobody notices until someone asks why an email, record, or order never arrived.

**Why it hurts:** Nothing routes failure details anywhere. A community audit of the 400 most-viewed public templates found 142 of the 205 templates that include settings had no error workflow set. The error trigger also only fires when a workflow runs. If a cron or webhook goes dead, there are zero executions, so nothing alerts and the instance looks healthy.

**Fix:** Create one workflow that starts with an Error Trigger. Set it as the error workflow in the settings of every production workflow. Test the whole chain before you rely on it: add a temporary Code node that throws, run once, and confirm the alert lands where a human reads it. Expired alert tokens and dead channels are found at the worst time otherwise. For triggers that can die silently, add a check from outside the workflow, such as a heartbeat run that alerts when expected executions stop arriving.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/how-to-set-up-an-error-workflow-in-n8n-before-production-fails/293914
- https://community.n8n.io/t/i-linted-the-400-most-viewed-n8n-templates-3-of-http-nodes-retry-1-have-a-timeout-2-of-67-webhooks-are-authenticated/315047
- https://docs.n8n.io/build/flow-logic/handle-errors-gracefully

### ERR-2: HTTP 200 with a failure inside the body

**Symptom:** The run is green. The API returned 200 with `success: false` or an error object in the body. Downstream nodes skip their logic and complete with nothing.

**Why it hurts:** n8n treats any 2xx as success. No node fails, so no error workflow runs and no retry happens. The same blindness hits nodes set to continue on fail: the audit above found 8 percent of templates had nodes continuing past errors with nothing downstream checking the error output.

**Fix:** After each HTTP Request, add an IF or Filter node that checks the status field in the response body. Route failures to a Stop And Error node or an alert. If you set On Error to continue using the error output, connect that output to a branch that inspects it. Assert one expected outcome after every important step so a wrong result fails on purpose.

**Caught by lint:** `BP-05` (flags HTTP Request nodes with neither continueOnFail nor an error workflow; it cannot see body checks)

**Sources:**
- https://community.n8n.io/t/the-silent-failure-when-your-n8n-workflow-succeeds-but-does-nothing/307116
- https://community.n8n.io/t/i-linted-the-400-most-viewed-n8n-templates-3-of-http-nodes-retry-1-have-a-timeout-2-of-67-webhooks-are-authenticated/315047

### ERR-3: Unconnected conditional branch drops items

**Symptom:** The false branch of an IF node, or one path of a Switch node, has no nodes on it. Items that take that path vanish. The run stays green.

**Why it hurts:** The audit above found 22 percent of templates had an IF or Switch with an unconnected branch. A branch labeled "should never happen" in the builder's head happens in production. Nothing fails, so nothing alerts, and the missing output is found days later.

**Fix:** End every branch somewhere. Route unexpected paths to a Stop And Error node, an alert, or a log write. Treat a silent exit as a bug.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/the-silent-failure-when-your-n8n-workflow-succeeds-but-does-nothing/307116
- https://community.n8n.io/t/i-linted-the-400-most-viewed-n8n-templates-3-of-http-nodes-retry-1-have-a-timeout-2-of-67-webhooks-are-authenticated/315047

### ERR-4: Retry on a paying or writing call, with a bad idempotency key

**Symptom:** A paid or writing API call runs twice. You are billed twice, or you get duplicate records, after a lost response or a manual retry from the executions list.

**Why it hurts:** Retry cannot tell "the request never arrived" from "it arrived and only the response was lost". A key built from `$execution.id` looks stable inside one run, but a manual retry starts a new execution with a new id, so the API sees a fresh operation and the duplicate goes through. A random key made in a Set node has the same problem.

**Fix:** Derive the idempotency key from the business data: an order id, a row id, or a hash of the request body. Send the same key on every attempt. Check how the provider treats duplicates and how long it remembers keys. Where the API takes no key, dedupe at your own boundary: hash the outgoing payload, store the response, and replay the stored result on a match. Keep a ledger table with a unique constraint on the operation key so a rerun is a no-op.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/retry-on-fail-paid-api-paid-twice-idempotency-key/315344
- https://community.n8n.io/t/retry-failed-n8n-workflows-without-creating-duplicate-side-effect/315733
- https://community.n8n.io/t/best-practice-for-centralized-error-handling-and-retry-from-failed-step-in-production-workflows/300785

### ERR-5: Retry On Fail semantics assumed, not checked

**Symptom:** Three distinct surprises. The wait between tries caps at 5000 ms. A retry re-runs the node for every input item, not just the one that failed. With On Error set to continue, all max tries run even after one succeeds.

**Why it hurts:** The cap makes long backoffs impossible without extra wiring. The whole-node retry repeats calls that already succeeded, which costs money on paid endpoints and duplicates writes on the healthy siblings. Users reported this as a bug; it was acknowledged and closed as not planned, so it will keep biting.

**Fix:** For waits over 5 seconds, set On Error to continue using the error output, route that output through a Wait node, and loop back into the failing node. For multi-item calls where a duplicate matters, feed items one at a time (Loop Over Items with batch size 1) so a retry touches one item. Do not combine Retry On Fail with continue-using-error-output on the same node.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/every-node-retry-on-fail-max-5000ms-why/273374
- https://community.n8n.io/t/http-request-node-retry-on-fail-feature/59538
- https://community.n8n.io/t/retry-on-fail-paid-api-paid-twice-idempotency-key/315344
