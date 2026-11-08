# Performance and memory

Recurring mistakes that make n8n workflows slow, bloated, or stuck.

## Entries

### PERF-1: Data accumulates across loop iterations until the run stalls

**Symptom:** A Loop Over Items run starts fast, gets slower every pass, then hangs. The editor shows one node holding hundreds of thousands of items.

**Why it hurts:** Items from every pass stay in memory for the whole execution. A workflow that processed 13 days of data in its first minute dropped to 2 days per minute by minute six, then stalled. The loop also keeps every output for the canvas view, which adds more overhead.

**Fix:** Set a batch size on the loop node. Push each batch into a sub-workflow so memory is released after every pass. For big jobs, split fetching and processing into separate executions, one per record or per day, driven by a queue. On HTTP Request, use the built-in pagination and batching options instead of pulling everything into one response.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/n8n-workflow-memory-bloat-processing-daily-sales-data-causes-exponential-slowdown-and-stalls/114385
- https://community.n8n.io/t/splitinbatches-clear-purge-cache-at-end-of-each-iteration/17917
- https://docs.n8n.io/build/flow-logic/loop
- https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest

### PERF-2: One Code node iterates thousands of items

**Symptom:** A single Code node loops over a large list, such as 5000 items. When it fails halfway, it starts over from item zero on retry.

**Why it hurts:** n8n does not checkpoint inside a code execution. A retry repeats the entire list, redoes finished work, and can duplicate side effects. All items also sit in memory at once.

**Fix:** Keep progress outside the node. Write each unit of work to a table with a status column, process in chunks, and mark units done as they complete. Resume then reads the table and continues where it stopped. Design so the run can be repeated safely, because the retry replays saved data for finished nodes but re-runs anything after the failure point.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/best-practice-for-centralized-error-handling-and-retry-from-failed-step-in-production-workflows/300785

### PERF-3: Sub-workflow fan-out writes one execution record per run

**Symptom:** A parent workflow fans out to sub-workflows, thousands of executions per run. Execution history shows runs stuck in "running" for hours. The recorded duration of each run is milliseconds.

**Why it hurts:** In normal mode, every execution writes a record to the database through the same event loop. At high volume the writes lag far behind real time, so history stops reflecting wall clock and the UI looks broken.

**Fix:** Stop saving successful executions for high-volume sub-workflows: set Save to none in the workflow settings, or set `EXECUTIONS_DATA_SAVE_ON_SUCCESS=none` on the instance. Turn off save-execution-progress for those workflows. Raise the database connection pool size above the default. If load keeps growing, move to queue mode so workers pick executions off a queue instead of serializing through one process.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/self-hosted-n8n-very-slow-on-sub-workflow-fan-out-execution-history-shows-24h-but-actual-run-is-200ms-performance-tuning-advice-needed/325416
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/scaling/enable-queue-mode

### PERF-4: One n8n process on a many-core host

**Symptom:** Executions queue up under load on a large server. Most CPU cores sit idle.

**Why it hurts:** A single n8n process runs on one event loop and can use one core. Bigger hardware does not help; the process is the bottleneck.

**Fix:** Run queue mode. Each worker is its own process and the main instance hands executions to the pool, so you scale by adding workers. Start with several workers on the same host, which practitioners report as an immediate throughput gain, and split across machines only when the whole host runs hot.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/self-hosted-n8n-very-slow-on-sub-workflow-fan-out-execution-history-shows-24h-but-actual-run-is-200ms-performance-tuning-advice-needed/325416
- https://docs.n8n.io/deploy/host-n8n/configure-n8n/scaling/enable-queue-mode

### PERF-5: Progress saving and editor-heavy debugging left on

**Symptom:** Runs feel slower than the work they do. Iterations drag, and pinned or open output data sits in the editor.

**Why it hurts:** Saving execution progress and keeping data for the canvas view cost memory and database writes on every step. An n8n team member confirmed both slow a loop down when left on while watching a run.

**Fix:** Turn off save-execution-progress for production workflows. Debug on a copy, then clear pinned data and close heavy output panes. Watch runs through metrics rather than through the editor when volume matters.

**Caught by lint:** none

**Sources:**
- https://community.n8n.io/t/splitinbatches-clear-purge-cache-at-end-of-each-iteration/17917
