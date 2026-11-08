# CI and version control

Recurring mistakes in how n8n workflows are backed up, versioned, and deployed.

## Entries

### VC-1: No exports, no backups

**Symptom:** A container restart reverts the instance to a state from weeks ago. Recent workflows and edits are gone. No copy exists outside the instance database.

**Why it hurts:** Workflow state lives in the database file inside the instance. Docker can also hold more than one named volume with different database files, so a redeploy can silently load an old copy. Two users in one thread lost weeks of work this way and had no restore path.

**Fix:** Export all workflows on a schedule with the CLI backup command and commit them to a git repository. Check `docker volume ls` for stray volumes after any host change. Test a restore, not just a backup: an export nobody has ever re-imported is a hope, not a backup.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/workflows-lost-after-docker-restart/222947
- https://community.n8n.io/t/workflow-backup-solution/9527
- https://community.n8n.io/t/backup-workflows-to-github/18036
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/use-the-command-line

### VC-2: Live edits with no versions or review

**Symptom:** Someone edits the running workflow in the editor. There is no diff, no second pair of eyes, and no rollback if the edit is wrong.

**Why it hurts:** On older n8n releases the editor wrote every save straight to the live workflow: no diff, no second pair of eyes, no rollback. Teams asked for git-based deployment for years before workflow versioning arrived, so un-upgraded instances still work this way. Current releases separate the draft from the published version, but the risk persists in a different shape: an editor who saves and activates without review still publishes unreviewed changes, just with one extra click.

**Fix:** Keep production on published workflow versions and promote drafts deliberately. Export a specific version by id for review, or export the published version of every workflow with the CLI. Where instance features are not available, a scheduled CLI export into git gives you diffs and rollback after the fact.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/version-control-workflows-got-created/595
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/use-the-command-line
- https://blog.n8n.io/introducing-n8n-v3/

### VC-3: Same template, same webhook path, second instance

**Symptom:** You deploy a template to a second instance or a second client. The webhook never activates. No error appears anywhere.

**Why it hurts:** Webhook and form trigger nodes keep a fixed path or production URL from the template. When the second deployment lands on the same instance as the first (or behind a shared ingress that routes one host), the two compete for one path and the newer registration fails silently, so a "deployment" that looks done is not live. Genuinely separate instances with their own hostnames do not collide; the trap is reusing a template inside one environment family.

**Fix:** Regenerate the webhook path for each deployment. Give each environment and each client its own path, credentials, and connection settings as part of the deploy checklist, not as an afterthought.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/the-silent-failure-when-your-n8n-workflow-succeeds-but-does-nothing/307116

### VC-4: Floating version, upgrade without testing

**Symptom:** An n8n update breaks Code nodes or running workflows in place. Rolling back is hard without exports.

**Why it hurts:** Major releases carry breaking changes, and the editor itself changes node behavior between versions. In one thread, an update left every Code node in an instance hanging, including workflows that had run untouched for months.

**Fix:** Pin the Docker image tag instead of tracking latest. Run a staging instance, import your exports there, and test before touching production. Read the breaking changes list for the release you move to. Version 3.0 ships a migration report that lists affected workflows and a suggested fix for each.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/help-code-node-stopped-working/90586
- https://blog.n8n.io/introducing-n8n-v3/
