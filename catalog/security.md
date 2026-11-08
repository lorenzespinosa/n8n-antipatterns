# Security

Recurring mistakes that expose n8n workflows and instances.

## Entries

### SAFE-1: Webhook endpoints open to the internet

**Symptom:** Any caller who finds or guesses the URL can trigger the workflow and whatever it does downstream.

**Why it hurts:** Webhook nodes default to no authentication. A community audit of the 400 most-viewed public templates found 2 of 67 webhook triggers used any authentication. An open webhook is a public API endpoint with your credentials behind it.

**Fix:** Turn on header or basic auth in the Webhook node settings, or verify a bearer token in a first Code node before any logic runs. Put rate limits at the reverse proxy, not inside the workflow.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/webhook-authentication/4566
- https://community.n8n.io/t/i-linted-the-400-most-viewed-n8n-templates-3-of-http-nodes-retry-1-have-a-timeout-2-of-67-webhooks-are-authenticated/315047

### SAFE-2: No signature check on inbound webhooks

**Symptom:** Forged requests pass. The same request, captured once, replays later and the workflow treats it as new.

**Why it hurts:** Basic and header authentication prove only that the caller holds a secret. They carry no provider-signed proof that the payload is intact and really came from that sender, and nothing stops a captured request from being replayed. Separately, payment and commerce senders retry on timeouts, so a workflow with no dedupe ships duplicate orders even without an attacker.

**Fix:** Verify an HMAC signature computed over the raw payload with a per-sender secret. Reject timestamps outside a short window. Dedupe on the event id the sender provides at the very start of the workflow, so retries become no-ops.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/webhook-security-multi-tenant-authentication/296737
- https://community.n8n.io/t/the-6-dimension-production-readiness-checklist-ive-been-using-on-every-n8n-workflow-review/296612

### SAFE-3: Self-hosted defaults left as installed

**Symptom:** The instance answers on plain HTTP. The public API is on. Anyone logged in can point an HTTP Request node at internal hosts.

**Why it hurts:** Defaults optimize the first-run experience, not exposure. An open instance leaks credentials and workflow data, and request nodes can be used to reach services that were never meant to be reachable from a workflow.

**Fix:** Work through the securing checklist in the docs: run the built-in security audit, enforce SSL, set up SSO or require 2FA, disable the public API if unused, block nodes you do not need, and enable SSRF protection so request nodes can only reach approved hosts and ranges.

**Caught by lint:** none

**Sources:**
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/security

### SAFE-4: Secrets and tenant data left in execution data

**Symptom:** Credentials or tenant tokens appear in execution input, output, and history. Anyone who can open executions can read them.

**Why it hurts:** Nodes echo what they receive. A Code node that fetched a secret holds it for the whole run, and one logging statement writes it into execution history where it outlives the run. In shared and multi-client setups this is exactly where data crosses tenant lines.

**Fix:** Redact execution data on the instance so input and output stay hidden. Keep an opaque reference in the workflow and resolve the real secret at the edge, outside the execution. Limit who can open execution data at all.

**Caught by lint:** none

**Sources:**
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/security
- https://community.n8n.io/t/webhook-security-multi-tenant-authentication/296737
