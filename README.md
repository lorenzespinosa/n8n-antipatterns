# n8n-antipatterns

A public catalog of recurring n8n workflow mistakes: the symptom, why it
hurts, the fix, and which n8n-lint rule catches it, if any. Every entry
cites public sources that were fetched and checked while building the
catalog.

The value is real sources and honest fixes, not volume. 30 entries, 7
categories, 39 sources.

## Use it as a review checklist

1. Copy the category lists below into your pull request template or
   review notes.
2. For each entry, check the workflow under review against the
   **Symptom** line.
3. Match a symptom, read the **Fix** line, and check the **Caught by
   lint** line to see whether a tool can hold the line for you.

A workflow is review-ready when every category has been walked once.

## Categories

- [Error handling](catalog/error-handling.md) (5 entries): failures that
  nobody sees, retries that duplicate work.
- [Credentials and secrets](catalog/credentials-and-secrets.md) (4
  entries): keys in the open, credentials that expire or spread.
- [Performance and memory](catalog/performance-and-memory.md) (5
  entries): loops that bloat, runs that stall, one core doing everything.
- [Workflow structure and naming](catalog/workflow-structure-and-naming.md)
  (4 entries): monolith canvases, silent renames, merge misuse.
- [Expressions](catalog/expressions.md) (4 entries): undefined values,
  legacy syntax, two clocks, wrong code mode.
- [CI and version control](catalog/ci-and-version-control.md) (4
  entries): no backups, live edits, deploy collisions, surprise upgrades.
- [Security](catalog/security.md) (4 entries): open webhooks, unsigned
  requests, default exposure, leaking execution data.

## Relation to n8n-lint

Entries carry a **Caught by lint** line. A rule id such as `SEC-01`,
`BP-04`, or `SCHEMA-03` refers to a rule in n8n-lint, a static checker
for exported n8n workflow JSON. It reads the export and reports these
rules before a workflow ever runs.

Most entries say **none**. Those patterns live in context a static check
cannot see: which branch "should never" fire, whether a key derives from
business data, whether anyone reads an alert channel. Use this catalog
for those; use the linter for what it catches; keep both in the loop.

## Sources policy

- Every entry cites at least one public source that was fetched and
  returned HTTP 200 on the date recorded in [sources.md](sources.md).
- Numbers quoted in entries come from the cited community audit thread
  and are attributed there, not presented as our own measurements.
- An entry with no source is either dropped or marked
  **practitioner-observed** with no attribution. The current catalog
  contains no such entries: all 30 are sourced.
- Sources are forum threads, product documentation, the vendor blog, or
  the changelog. No private or internal material.

## Checking links offline

The repository ships an offline validator. It checks that every URL in
the markdown is well-formed (http or https, public host only), that
every relative link resolves to a file in the tree, and that every URL
cited in catalog entries appears in sources.md. It makes no network
requests.

Run it from the repository root:

    zsh scripts/check-links.zsh

Run the built-in self test, which plants bad links in a temporary tree
and expects the validator to catch them:

    zsh scripts/check-links.zsh --self-test

Both commands exit 0 on success and 1 on failure.

## Contributing

New entries need at least one verifiable public source: a forum thread,
a docs page, a changelog entry, or a vendor blog post. Verify the URL
returns 200 before sending the change, add it to sources.md with the
fetch date, and run the link checker.

## License

[MIT](LICENSE)
