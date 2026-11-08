# Credentials and secrets

Recurring mistakes in how n8n workflows store, share, and rotate credentials.

## Entries

### CRED-1: Secrets hardcoded in parameters and URLs

**Symptom:** An API key sits in a query string, a header field, or a Code node. Every export and every pasted workflow JSON carries it.

**Why it hurts:** Anyone who gets the export gets the key. Keys in URLs also land in logs, proxies, and execution history. In one public forum thread, a user pasted a workflow with a live key in it. The key was indexed by search engines within minutes and the post could not be edited to remove it. The only fix was to revoke and reissue.

**Fix:** Store keys in n8n credentials, or read them from environment variables with `$env`. Move keys out of URLs into a header the node sends. If a secret has been shared anywhere, revoke it first, then rotate. Treat any workflow JSON pasted in public as burned.

**Caught by lint:** `SEC-01` (keys, tokens, and passwords in node parameters), `SEC-04` (auth tokens in URL query parameters)

**Sources:**
- https://community.n8n.io/t/nodes-parameters-url-https-newsapi-org-v2-everything-apikey-setup1-first-json-apikey-q-json-output-clean-company-name-from-datetime-now-minus-days-setup1-first-json-newsage-tof/258049

### CRED-2: Expired OAuth credentials fail before the request

**Symptom:** An error such as "Unable to sign without access token" at the signing step. There is no HTTP status code to check, so error handling built around response codes misses it.

**Why it hurts:** The credential aged out. The failure happens before the call, outside the logic that handles API errors. It also masquerades as a workflow bug and burns debugging time on code that is fine.

**Fix:** Match on this error class separately from HTTP failures. Split alerts by cause: auth expiry needs one fix-once action, an API outage needs a cooldown, a data change needs a person. Without that split, repeat alerts get ignored and the real auth failures get lost in the noise.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/the-silent-failure-when-your-n8n-workflow-succeeds-but-does-nothing/307116

### CRED-3: Personal credentials in shared workflows, credential files passed around

**Symptom:** A shared workflow breaks when its owner leaves the team. Members export credentials with the CLI and hand the files over.

**Why it hurts:** Exports expose credential details. Personal credentials tie running automations to one account, and a workflow owned by a departed login becomes an orphan nobody can fix.

**Fix:** Use the instance features for this. Plans with projects and credential sharing let a team own credentials together. On self-hosted, credential overwrites set credential data instance-wide so users authenticate without ever seeing client secrets. Do not share exported credential files; treat them like plaintext.

**Caught by lint:** `SEC-05` (credential names and ids that leak internal naming, a weak signal for review)

**Sources:**
- https://community.n8n.io/t/how-do-you-handle-api-credentials-in-n8n-workflows-you-share-with-teammates/288743
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/use-the-command-line

### CRED-4: One shared key across many workflows, rotated without a map

**Symptom:** A client or provider rotates one API key. Several unrelated automations go silent at once.

**Why it hurts:** Nobody knows which workflows use which credential. One rotation without a dependency map silently kills everything that shared the key.

**Fix:** Keep a map of every credential to the workflows that use it. Name credentials by service and environment so the map stays readable. Give each workflow or client its own key where the provider allows it, so one rotation touches one thing.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/the-6-dimension-production-readiness-checklist-ive-been-using-on-every-n8n-workflow-review/296612
