# Sources

Every catalog entry cites at least one URL from this list. Each URL was
fetched and returned HTTP 200 on 2026-11-07. Doc URLs are the final
addresses after redirects.

## Community forum threads

- https://community.n8n.io/t/how-to-set-up-an-error-workflow-in-n8n-before-production-fails/293914
  Setting up error workflows, untested alert chains, and blind spots when triggers die.
- https://community.n8n.io/t/the-silent-failure-when-your-n8n-workflow-succeeds-but-does-nothing/307116
  Green runs that did nothing: empty branches, 200 responses with errors in the body, OAuth expiry, webhook path conflicts.
- https://community.n8n.io/t/retry-failed-n8n-workflows-without-creating-duplicate-side-effect/315733
  Duplicate side effects on retry, idempotency keys derived from business data, webhook response modes causing refires.
- https://community.n8n.io/t/retry-on-fail-paid-api-paid-twice-idempotency-key/315344
  Retry On Fail double-billing on paid calls, key derivation, whole-node retries repeating healthy items.
- https://community.n8n.io/t/best-practice-for-centralized-error-handling-and-retry-from-failed-step-in-production-workflows/300785
  Centralized error handling in queue mode, retry semantics, durable worklists for large Code node iterations.
- https://community.n8n.io/t/every-node-retry-on-fail-max-5000ms-why/273374
  The 5000 ms retry wait cap and the Wait node loop pattern.
- https://community.n8n.io/t/http-request-node-retry-on-fail-feature/59538
  Retry On Fail re-running all items, acknowledged as a bug and closed as not planned.
- https://community.n8n.io/t/i-linted-the-400-most-viewed-n8n-templates-3-of-http-nodes-retry-1-have-a-timeout-2-of-67-webhooks-are-authenticated/315047
  Community audit of the 400 most-viewed public templates: retry, timeout, webhook auth, error workflow, and branch coverage counts.
- https://community.n8n.io/t/the-6-dimension-production-readiness-checklist-ive-been-using-on-every-n8n-workflow-review/296612
  Production readiness review checklist: idempotency, retries, audit trail, dead letter queues, ownership, rotation.
- https://community.n8n.io/t/n8n-workflow-memory-bloat-processing-daily-sales-data-causes-exponential-slowdown-and-stalls/114385
  Memory bloat in loops and queue-driven processing alternatives.
- https://community.n8n.io/t/self-hosted-n8n-very-slow-on-sub-workflow-fan-out-execution-history-shows-24h-but-actual-run-is-200ms-performance-tuning-advice-needed/325416
  Execution record write lag on sub-workflow fan-out, save settings, pool size, queue mode, one core per process.
- https://community.n8n.io/t/splitinbatches-clear-purge-cache-at-end-of-each-iteration/17917
  Iteration slowdown from accumulated data and the cost of progress saving and editor views.
- https://community.n8n.io/t/webhook-authentication/4566
  Webhook authentication options.
- https://community.n8n.io/t/webhook-security-multi-tenant-authentication/296737
  HMAC verification, replay windows, per-tenant secrets, egress credential handling.
- https://community.n8n.io/t/my-9-am-workflow-fired-at-1-am-the-schedule-trigger-timezone-gotcha-and-the-fix/322339
  Schedule trigger timezone defaults and fixes.
- https://community.n8n.io/t/n8n-output-timezone-mismatch-with-expression-and-cron-timezone/13374
  GENERIC_TIMEZONE versus process TZ mismatch.
- https://community.n8n.io/t/workflows-lost-after-docker-restart/222947
  Instance state reverting weeks after restarts, multiple Docker volumes.
- https://community.n8n.io/t/workflow-backup-solution/9527
  Backup approaches, CLI export, scheduled commits.
- https://community.n8n.io/t/backup-workflows-to-github/18036
  Scheduled workflow backups to git repositories.
- https://community.n8n.io/t/version-control-workflows-got-created/595
  The long-running feature request for workflow version control.
- https://community.n8n.io/t/help-code-node-stopped-working/90586
  Code node mode mismatches, upgrade breakage, Function node deprecation.
- https://community.n8n.io/t/how-do-you-handle-api-credentials-in-n8n-workflows-you-share-with-teammates/288743
  Credential sharing across teams, credential overwrites, risks of exported credentials.
- https://community.n8n.io/t/some-problems-with-splitinbatches/19788
  Loop Over Items and Merge interaction pitfalls.
- https://community.n8n.io/t/what-is-the-best-pattern-for-triggering-n-sub-workflows-in-parallel-and-resuming-main-workflow-when-all-complete/233446
  Fan-out and fan-in with callbacks, why Merge cannot wait for async branches.
- https://community.n8n.io/t/workflow-template-rejected-3-times-need-guidance-on-sticky-note-requirements/324146
  Sticky note standards enforced by template review.
- https://community.n8n.io/t/nodes-parameters-url-https-newsapi-org-v2-everything-apikey-setup1-first-json-apikey-q-json-output-clean-company-name-from-datetime-now-minus-days-setup1-first-json-newsage-tof/258049
  Keys in URLs, a live key pasted in public, cross-branch references, legacy expression syntax.

## Documentation

- https://docs.n8n.io/build/flow-logic/handle-errors-gracefully
  Error workflows, the Error Trigger, Stop And Error.
- https://docs.n8n.io/build/flow-logic/loop
  Loop Over Items behavior, batch size, combining loops with Wait.
- https://docs.n8n.io/build/flow-logic/break-workflows-into-smaller-parts
  Sub-workflows and calling workflows from workflows.
- https://docs.n8n.io/build/work-with-data/transform-data/expression-reference/nodeinputdata
  Current node input methods: $input.all(), $input.first(), $input.item.
- https://docs.n8n.io/build/code-in-n8n/use-built-in-shortcuts
  Built-in variables and methods for expressions and code.
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest
  HTTP Request options: batching, pagination, timeout.
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger
  Timezone resolution order and defaults.
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/security
  Securing self-hosted instances: audits, SSL, SSO, SSRF protection, execution data redaction.
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/scaling/enable-queue-mode
  Queue mode architecture, workers as separate processes.
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/use-the-command-line
  CLI export, backup flag, version and published exports.
- https://docs.n8n.io/build/understand-workflows/workflow-components/add-notes-and-documentation
  Sticky notes for workflow documentation.
- https://docs.n8n.io/contribute/create-templates/sticky-note-guidelines
  Template sticky note guidelines.

## Blog

- https://blog.n8n.io/introducing-n8n-v3/
  Version 3.0 breaking changes, workflow versions, migration report, Function node retirement.

## Consulted but not cited

- https://docs.n8n.io/changelog/release-notes
  Scanned for deprecation and breaking change entries. Individual entries cited above cover the same ground.
- https://blog.n8n.io/
  Index page used for discovery.

Fetch date for all URLs: 2026-11-07.
