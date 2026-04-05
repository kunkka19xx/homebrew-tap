# AGENTS.md
Guidance for agentic coding assistants working in this repository.

## Repo Context
- Repository type: Homebrew tap scaffold.
- Current files are minimal (`README.md`, `LICENSE`, `.gitignore`).
- No formula files exist yet, but expected work is Ruby formula/cask authoring.

## Instruction Priority
Follow this order when instructions conflict:
1. Direct user request.
2. System/developer/runtime tool instructions.
3. Repository rule files.
4. This `AGENTS.md`.

## Checked Rule Files
These locations were checked and are currently absent:
- `.cursor/rules/`
- `.cursorrules`
- `.github/copilot-instructions.md`
If these appear later, treat them as higher-priority constraints and update this file.

## Expected Layout
- `Formula/<name>.rb` for formulae.
- `Casks/<name>.rb` for casks (if added).
- `scripts/` for repo helpers (if added).

## Environment Quick Check
Run from repository root:
```bash
brew --version
ruby --version
```
Optional health checks:
```bash
brew tap --repair
brew doctor
```

## Build Commands
This repo has no compiled application build yet. For a tap, build means install from source.
- Install one formula from file:
```bash
brew install --build-from-source ./Formula/<formula>.rb
```
- Rebuild an installed formula:
```bash
brew reinstall --build-from-source <formula>
```
- Remove local install state:
```bash
brew uninstall --force <formula>
```

## Lint And Static Checks
- Ruby syntax check (single file):
```bash
ruby -c Formula/<formula>.rb
```
- Homebrew style check (single formula):
```bash
brew style Formula/<formula>.rb
```
- Style autofix where supported:
```bash
brew style --fix Formula/<formula>.rb
```
- Strict audit (single formula):
```bash
brew audit --strict Formula/<formula>.rb
```
- New formula strict audit:
```bash
brew audit --new-formula --strict Formula/<formula>.rb
```

## Test Commands
There is no standalone `spec/` or `test/` suite currently.
Testing is formula-driven.
- Run one formula test block:
```bash
brew test <formula>
```
- Common install-plus-test loop:
```bash
brew install --build-from-source ./Formula/<formula>.rb
brew test <formula>
```
- CI-like broad checks (heavyweight):
```bash
brew test-bot --only-formulae
```

## How To Run A Single Test Here
When asked for "a single test", use this order:
1. `brew test <formula>` (preferred runtime verification).
2. `brew audit --strict Formula/<formula>.rb` (single target policy check).
3. `ruby -c Formula/<formula>.rb` (single-file syntax check only).

## Code Style Guidelines

### Imports / Requires
- Formula files typically rely on Homebrew DSL and need no explicit `require`.
- Add `require` only when truly necessary and consistent with Homebrew practices.
- Avoid introducing custom abstraction layers for simple formula logic.

### Formatting
- Use 2-space indentation in Ruby files.
- Prefer readable multi-line steps over dense one-liners.
- Prefer double quotes unless single quotes improve clarity.
- No trailing whitespace; always end files with a newline.
- Keep `install` and `test do` commands explicit and easy to scan.

### Types / Interfaces
- Ruby is dynamic; prefer clear, predictable method contracts.
- Use explicit arguments to helper and `system` calls.
- Avoid metaprogramming for routine packaging tasks.

### Naming Conventions
- Formula file path: `Formula/<name>.rb`.
- Class name: CamelCase mapping of formula name.
- Methods and variables: `snake_case`.
- Use descriptive names; avoid cryptic abbreviations.

### Formula Structure
- One formula class per file.
- Keep metadata near top in logical order: `desc`, `homepage`, `url`, `sha256`, `license`.
- Group/sort `depends_on` entries for readability.
- Add `bottle do` only when bottle management is intentional.
- Provide a meaningful `test do` block whenever possible.

### Error Handling
- Prefer fail-fast behavior; let command failures surface naturally.
- Avoid broad `rescue` usage in formula code.
- Validate assumptions in `test do` instead of swallowing errors.
- If a workaround is necessary, add a short reason comment.

### Security / Supply Chain
- Always pin and verify `sha256` for stable sources.
- Prefer `https` download URLs.
- Avoid opaque remote installer scripts where direct steps are possible.
- Update source URLs and checksums together.

## Recommended Validation Before Hand-off
For changes to one formula, run:
```bash
ruby -c Formula/<formula>.rb
brew style Formula/<formula>.rb
brew audit --strict Formula/<formula>.rb
brew install --build-from-source ./Formula/<formula>.rb
brew test <formula>
```
For docs-only edits, verify examples and paths remain accurate.

## Commit / PR Guidance
- Keep diffs focused; avoid unrelated edits.
- Explain why in commit/PR text, not only what changed.
- Include relevant style/audit/test outcomes when applicable.
- Do not commit unless the user explicitly asks.

## Maintenance
As the tap grows, update this file with real formula names, CI commands from workflows,
and any Cursor/Copilot rule summaries once rule files are added.
