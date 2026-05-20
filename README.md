# python-services-rules

Shared **Cursor agent rules** (`.mdc`) for Python microservices. Rules describe **how to code** (architecture, DI, repos, HTTP conventions) — not product requirements. Designed as a reusable constitution: adopt it in any Python microservice project, regardless of platform.

**Version:** see [`VERSION`](VERSION) (currently **0.5.1**) · [CHANGELOG](CHANGELOG.md)

---

## Layout

This repository root **is** the contents of a consumer's **`.cursor/rules/`** directory. Every `.mdc` file at the root is loaded by Cursor automatically when the repo is mounted as a submodule:

```
python-services-rules/     # mounted as .cursor/rules/ in service repos
  VERSION
  README.md
  CHANGELOG.md
  architecture.mdc
  code-guidelines-index.mdc
  database-migrations.mdc
  dependency-injection.mdc
  fail-fast.mdc
  http-api-conventions.mdc
  infra-services.mdc
  logging-loguru.mdc
  pydantic-schemas.mdc
  python-imports.mdc
  python-tooling.mdc
  repository-pattern.mdc
  strong-typing.mdc
  testing-verify-flows.mdc
```

---

## Consumer: first-time setup

### 1. Add as a git submodule

Run from the **consumer service repo root** (e.g. `abhilekh/`, `kavach/`):

```bash
# Remove any previously copied rules
rm -rf .cursor/rules

# Add this repo as a submodule at .cursor/rules
git submodule add https://github.com/autrio10x/python-services-rules.git .cursor/rules

# Pin to the current stable release
cd .cursor/rules && git checkout v0.4.0 && cd ../..

# Commit the submodule pointer
git add .gitmodules .cursor/rules
git commit -m "Add shared Python service Cursor rules at .cursor/rules (v0.4.0)"
```

Cursor reads **`.cursor/rules/*.mdc`** directly — no install script, no copy step.

### 2. Add AGENTS.md at the consumer repo root

`AGENTS.md` tells the Cursor agent the rules boundary and where product documentation lives. Create it at the consumer repo root:

```markdown
# AGENTS.md

## Rules

Shared coding rules live in `.cursor/rules/` (git submodule — do not edit files there).
To propose a rule change, open a PR on [python-services-rules](https://github.com/autrio10x/python-services-rules).

## Product documentation

Product-specific requirements, ADRs, and route catalogs live in:

- `docs/specification/product/` — capabilities and feature requirements
- `docs/specification/adr/`     — architecture decision records
- `README.md`                   — setup, env vars, local run commands
- `tests/README.md`             — verify and debug test instructions

Start here before making changes to API behaviour, routes, or integrations.

## Reference rule modules

| Concern                     | Rule file                        |
|-----------------------------|----------------------------------|
| Layered architecture        | `.cursor/rules/architecture.mdc` |
| Dependency injection        | `.cursor/rules/dependency-injection.mdc` |
| Repository pattern          | `.cursor/rules/repository-pattern.mdc` |
| Pydantic / enums / JSONB    | `.cursor/rules/pydantic-schemas.mdc` |
| Logging                     | `.cursor/rules/logging-loguru.mdc` |
| Tooling (pyright, linting)  | `.cursor/rules/python-tooling.mdc` |
```

### 3. Add new tooling required by v0.4.0

These tools are now required by `python-tooling.mdc`. **Activate your conda env first**, then add them to each service repo:

```bash
conda activate <env-name>

# One-time machine config — Poetry uses the active conda interpreter
poetry config virtualenvs.prefer-active-python true

# Type checker + architectural layer enforcement
poetry add --group dev pyright import-linter
```

**`pyproject.toml`** — add pyright config:

```toml
[tool.pyright]
pythonVersion = "3.12"
pythonPlatform = "Linux"
typeCheckingMode = "basic"   # existing services; use "strict" for new services
venvPath = "."
venv = ".venv"
```

**`.importlinter`** — add layer contract at repo root (adapt paths to match this service):

```ini
[importlinter]
root_packages =
    src

[importlinter:contract:layer-architecture]
name = Layered architecture — no cross-layer imports
type = layers
layers =
    src.api
    src.business_services
    src.database.postgres.repository
    src.database.postgres.schema
```

**`Makefile`** — add at repo root:

```makefile
.PHONY: check format lint types layers test

check: format lint types layers

format:
	poetry run black --line-length 100 src/ tests/

lint:
	poetry run ruff check --fix src/ tests/

types:
	poetry run pyright

layers:
	poetry run lint-imports

test:
	poetry run pytest
```

**`.pre-commit-config.yaml`** — add at repo root:

```yaml
repos:
  - repo: https://github.com/psf/black
    rev: "24.x.x"
    hooks:
      - id: black
        args: ["--line-length=100"]

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: "v0.x.x"
    hooks:
      - id: ruff
        args: ["--fix"]

  - repo: https://github.com/RobertCraigie/pyright-python
    rev: "v1.x.x"
    hooks:
      - id: pyright

  - repo: local
    hooks:
      - id: import-linter
        name: import-linter
        entry: lint-imports
        language: system
        pass_filenames: false
```

Install pre-commit hooks once after cloning (conda env must be active):

```bash
conda activate <env-name>
pre-commit install
```

### 4. Pin version in consumer README

Add to the consumer repo's `README.md`:

```markdown
## Cursor rules

Shared coding rules: [`python-services-rules`](https://github.com/autrio10x/python-services-rules) pinned at **v0.4.0**.
To update: see [Bump rules version](#bump-rules-version) below.
```

---

## Consumer: bump rules version

Run from the consumer repo root:

```bash
cd .cursor/rules
git fetch --tags
git checkout v0.4.0      # replace with target version
cd ../..
git add .cursor/rules
git commit -m "Bump shared Cursor rules to v0.4.0"
```

**Before bumping**, read the [CHANGELOG](CHANGELOG.md) for the target version. Releases marked with breaking changes require code changes in the consumer repo before or alongside the bump — do not bump and move on without reading the migration notes.

---

## Release process (architecture team)

Follow this checklist in order every time rules are changed and a new version is cut.

### Step 1 — Make and review changes

```bash
# Work on a branch
git checkout -b rules/short-description

# Edit *.mdc files at repo root
# Run: git diff to review
```

Rule changes must be reviewed by at least one other architecture team member before merging to `main`.

### Step 2 — Update VERSION and CHANGELOG

```bash
# Bump VERSION (semver)
# - PATCH (x.y.Z): clarifications, wording fixes, non-breaking additions
# - MINOR (x.Y.0): new guidance sections, additive tooling requirements
# - MAJOR (X.0.0): breaking changes that require consumer code changes
echo "0.3.0" > VERSION
```

Add a section to `CHANGELOG.md` (see format below):
- List every `.mdc` file changed and what changed
- Clearly mark **Breaking** vs **Additive** changes
- Write a migration guide for any breaking change

### Step 3 — Update README version reference

```bash
# Replace the version number in README.md header
# "currently **0.2.0**"  →  "currently **0.3.0**"
```

### Step 4 — Commit, tag, and push

```bash
git add -A
git status   # verify only intended files changed

git commit -m "$(cat <<'EOF'
Release v0.4.0 — <short description of the main change>

<bullet summary of what changed, e.g.:>
- Unify @inject pattern across infra and business services
- Add pyright + import-linter + Makefile to tooling standard
- Add structured JSON logging guidance
EOF
)"

git tag v0.4.0
git push origin main
git push origin v0.4.0
```

### Step 5 — Notify consumer teams

After pushing the tag, communicate to service teams:
- New version number
- Whether the bump is **breaking** (requires code changes) or **safe to apply directly**
- Link to the CHANGELOG section for the release

---

## Governance

- **Architecture team** owns this repo. Service teams **do not** edit `.cursor/rules/` in product repos.
- Propose rule changes via PR on this repo. Consumer repos only update the submodule pointer — they never diverge from a released tag.
- **Do not** `gitignore` `.cursor/rules` in consumers — that breaks the pinned submodule for the team.
- **Product-specific** requirements, ADRs, and route catalogs belong in each service repo under `docs/specification/` — not here.

---

## What stays in each service repo

| Location | Purpose |
|----------|---------|
| `docs/specification/product/` | Requirements, capabilities, features |
| `docs/specification/adr/` | Architecture decision records |
| `README.md`, `tests/README.md` | Setup, env vars, verify commands |
| `AGENTS.md` | Agent router: do not edit `.cursor/rules`; link product docs |

---

## Rule index

See [`code-guidelines-index.mdc`](code-guidelines-index.mdc) for the full module table.

---

## Reference implementations

Nominate services from your own platform as reference implementations and document them in your `AGENTS.md` or platform wiki. Useful profiles to designate:

| Profile | What to point to |
|---------|-----------------|
| **Layered shell + DI lifecycle** | A service that has `business_services/`, `database/`, `infra_services/`, full DI wiring, and lifespan hooks |
| **JWT issuer** | The identity service that issues platform tokens — defines claim shapes other services verify |
| **Internal consumer only** | A service with no `api/internal/` that only calls other services' internal APIs |

---

## Migration from 0.1.x to 0.2.x

**0.1.x** used `cursor/rules/*.mdc` and a copy/install step. **0.2.0+** mounts this repo directly at `.cursor/rules` via submodule — remove any previously copied rules directory at the consumer root if you used the old layout.
