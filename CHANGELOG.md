# Changelog

All notable changes to `python-services-rules` are documented here.

Format: **Breaking** changes require code changes in consumer repos before or alongside the version bump. **Additive** changes are safe to adopt incrementally.

---

## v0.5.7

### Summary

Link frozen spec-layout SSOT to launchpad playbook (not private tenant meta).

### Changes

- **`testing-verify-flows.mdc`** — point at [launchpad `playbook/spec-layout.md`](https://github.com/drivestream-lab/launchpad/blob/main/playbook/spec-layout.md)

### Migration guide

- Optional submodule bump: `git checkout v0.5.7` in `.cursor/rules`
- No application code changes required

---

## v0.5.6

### Summary

Agent-workflows boundary in SDD mdc (no prayog skill catalogs in constitution). OSS playbook link. MDC boundary CI check.

### Migration guide

- Optional submodule bump: `git checkout v0.5.6` in `.cursor/rules`
- No application code changes required

---

## v0.5.5

### Summary

Remove **`docs/specification/harness/`** from the SDD hierarchy. Testing ground truth lives under **`docs/specification/as-built/`** (`testing-and-verification.md` + `implementation-status.md`) — mandatory frozen layout per drivestream-meta `playbook/spec-layout.md`.

### Changes

#### `testing-verify-flows.mdc` — Corrective

- **Replaced** harness folder SSOT with **`as-built/testing-and-verification.md`**
- **Forbidden** `docs/specification/harness/`

#### `spec-driven-development.mdc` — Corrective

- **Merged** harness hierarchy level into **as-built** layer

#### `python-tooling.mdc`, `code-guidelines-index.mdc` — Corrective

- **Updated** maintenance paths to as-built testing doc

### Migration guide

- Move `docs/specification/harness/*` → `docs/specification/as-built/testing-and-verification.md`
- Delete **`harness/`** folder
- Update `AGENTS.md`, `tests/README.md`, and submodule pointer references

---

## v0.5.4

### Summary

Testing and SDD rules derived from the Parichay harness audit (BOOTSTRAP-DS-001 P2). Encodes as-built verify/pytest layout, `tests/config.yaml` canon, CI vs live boundaries, no-overlap principle, and DriveStream truth hierarchy. **`tests/unit/`** documented as a deferred target — not required until a per-service quality epic.

### Changes

#### `testing-verify-flows.mdc` — Additive / Corrective

- **Added** standard folder layout (`verify/`, `debug/`, `_helpers/`, `config.yaml`).
- **Added** toolchain vs runtime split; verify/debug use **`tests/config.yaml`**, not **`.env`**, as primary local config.
- **Added** pytest collection boundaries (`--ignore` verify/debug/e2e); **`tests/unit/`** as deferred target.
- **Added** `verify_all` patterns: aggregator, in-process provision session, scripts outside aggregator.
- **Added** CI vs live verify table, feature map in **`tests/README.md`**, harness doc SSOT pattern.
- **Added** unit vs verify no-overlap rule.

#### `spec-driven-development.mdc` — Additive (new file)

- **Added** DriveStream truth hierarchy: rules → **`AGENTS.md`** → product → ADR → as-built → harness.
- **Added** update discipline, PR traceability, constitution boundary, execution chat rule.

#### `python-tooling.mdc` — Additive / Corrective

- **Updated** canonical **`make test`** target with `--ignore` for verify/debug/e2e.
- **Added** current vs target test layout (`tests/` today; **`tests/unit/`** deferred).
- **Added** cross-link to **`spec-driven-development.mdc`**.

#### `code-guidelines-index.mdc` — Additive

- **Added** **`spec-driven-development.mdc`** to index; expanded per-repo documentation table.

### Migration guide

- **Non-breaking** for existing services on v0.5.3 — adopt when bumping submodule.
- Align **`Makefile` `test`** target with canonical `--ignore` flags if not already.
- Add **`spec-driven-development.mdc`** automatically via submodule bump — no consumer code change required.
- Services with harness audits should keep **`docs/specification/harness/`** and **`tests/README.md`** in sync with these rules.

---

## v0.5.3

### Summary

Remove `verify` target from the canonical Makefile template. Verify invocation is service-specific and belongs in each service repo's `tests/README.md`.

### Changes

#### `python-tooling.mdc` — Corrective

- **Removed** `verify` target from canonical Makefile template — invocation path, env name, and whether conda is needed varies per service.
- **Updated** tooling vs runtime table: `verify_all` rows now show `.venv/bin/python -m tests.verify.verify_all` directly (no `make verify`); `conda run -n <env>` noted as the correct pattern when conda is needed (not `conda activate` which does not work in Makefile subshells).
- **Updated** business-flow verification section: document invocation in `tests/README.md` per service, not in the shared Makefile.

---

## v0.5.2

### Summary

Complete rewrite of `python-tooling.mdc` environment and tooling guidance. Eliminates the Option A / Option B split — one approach, fully documented, with all 7 practitioner feedback points incorporated.

### Changes

#### `python-tooling.mdc` — Additive / Corrective

- **Baked in single approach**: conda for Python version, explicit `python -m venv .venv` + `poetry env use .venv/bin/python` for the toolchain env. No options, no per-machine prerequisites, deterministic.
- **Added `make setup` + `scripts/setup_dev.sh`**: canonical first-time onboarding command. Script handles `.venv` creation, `poetry install`, and `pre-commit install` in one shot.
- **Fixed pre-commit hooks**: replaced `RobertCraigie/pyright-python` remote hook (broken — creates an isolated sandbox with no project package visibility) and `language: system` bare entry for import-linter (breaks in non-interactive shells) with `local` hooks calling `.venv/bin/pyright` and `.venv/bin/lint-imports` directly.
- **Fixed `pyrightconfig.json`**: added `"exclude": [".venv", "postgres_migrations"]` — without this pyright scans all installed packages as project source (5s → 2+ min per check).
- **Removed `pythonPlatform` from dev config**: auto-detect is correct for local dev. `"pythonPlatform": "Linux"` belongs only in CI-specific config.
- **Documented `.venv` creation failure mode**: poetry installed inside conda env does not auto-create `.venv` — explicit `python -m venv .venv && poetry env use` is required.
- **Added tooling vs runtime env split**: `.venv` owns the toolchain (no conda needed); conda is activated only for live-infra verify flows.
- **Fixed pre-commit install instruction**: no conda activation needed — `.venv/bin/pre-commit install` is self-contained. `make setup` handles it.
- **Updated Makefile targets**: use `.venv/bin/<tool>` directly instead of `poetry run <tool>` for determinism.

### Migration guide

- Replace `.pre-commit-config.yaml` hooks: remove `RobertCraigie/pyright-python` and bare `lint-imports` entries; add local hooks pointing to `.venv/bin/pyright` and `.venv/bin/lint-imports`.
- Add `"exclude": [".venv", "postgres_migrations"]` to `pyrightconfig.json`.
- Remove `pythonPlatform` from local pyright config.
- Add `scripts/setup_dev.sh` and `make setup` target.
- Update Makefile targets to use `.venv/bin/<tool>` instead of `poetry run <tool>`.

---

## v0.5.1

### Summary

Corrections to `python-tooling.mdc` environment guidance based on team pushback. Both changes are non-breaking — existing setups continue to work unchanged.

### Changes

#### `python-tooling.mdc` — Additive / Corrective

- **Revised** environment management section: replaced the single Option A (`prefer-active-python true`) mandate with two explicitly documented options. Option A (single env, new services) and Option B (dual env with `.venv` + `pyrightconfig.json`, existing services). Documents the failure mode of each. The previous guidance incorrectly presented Option B as wrong.
- **Revised** pyright config section: config location and `venvPath`/`venv` presence now depend on which option the service uses. Option A → `[tool.pyright]` without `venvPath`; Option B → `pyrightconfig.json` with `venvPath`.
- **Revised** dependencies section: scoped `environment.yml` requirement. Required only for services with native conda-managed dependencies (CUDA, system libs, compiled extensions). Pure Python services do not need it — `pyproject.toml`'s Python version constraint enforces the interpreter version at `poetry install` time.

---

## v0.5.0

### Summary

Nine targeted rule additions and clarifications based on team feedback from making service codebases pyright-compliant. All changes are additive — no breaking changes to existing code patterns.

### Changes by file

#### `dependency-injection.mdc` — Additive

- **Added** `is_configured()` anti-pattern section: making a required dependency optional at the settings level with `is_configured()` guards violates fail-fast. Required deps use `base_url: str` (no default). Genuinely optional deps require ADR + WARNING log + test coverage.
- **Added** explicit `await service.initialize()` code example for the startup loop. Both infra and business service phases must call `await initialize()` — `provide_service()` / `injector.get()` only constructs; it does not initialize.

#### `pydantic-schemas.mdc` — Additive

- **Added** `Field(default=None)` rule: always use keyword form for defaults. `Field(None, description="...")` (positional) is not recognised as a default by pyright's Pydantic v2 stubs and causes type errors at every call site.
- **Added** `extra="allow"` + `model_validate` guidance: pyright rejects undeclared kwargs on `__init__` even with `extra="allow"`. Always use `Model.model_validate({...})` at construction sites with dynamic fields.

#### `python-tooling.mdc` — Additive

- **Added** `pre-commit = "^4.0"` as a required dev dependency in `pyproject.toml`. `poetry run pre-commit install` is the canonical portable setup command.
- **Added** `pyrightconfig.json` vs `[tool.pyright]` guidance: `[tool.pyright]` is the default for local dev with conda + `prefer-active-python true`; `pyrightconfig.json` with explicit `pythonPath` is the fallback for CI environments where auto-detection fails.

#### `infra-services.mdc` — Additive

- **Added** session factory Protocol section: `PostgresSessionFactory` must be a `Protocol` (structural typing), not an abstract class. `@asynccontextmanager` on an abstract method causes pyright type errors. Protocol-based definition is also architecturally better — structural contract, no inheritance required, mock-friendly.

#### `logging-loguru.mdc` — Additive

- **Strengthened** message style section: explicit wrong/right examples showing that `{}` placeholders embed values into the message string (defeating structured logging), while named kwargs produce discrete queryable JSON fields. Rule: static label in message, all variable values as named kwargs.

#### `repository-pattern.mdc` — Additive

- **Added** `__tablename__` rule for ORM schema classes: do not use `@declared_attr __tablename__` on abstract base classes — it causes pyright type mismatches when subclasses set it as a plain string. Every concrete schema class must declare `__tablename__` explicitly.

### Migration guide

All changes are additive — no code changes required in consumer repos to adopt this version. Apply the new patterns going forward:

1. Replace `Field(None, ...)` with `Field(default=None, ...)` across all Pydantic models
2. Replace `Model(extra_field=...)` with `Model.model_validate({...})` for `extra="allow"` models
3. Add `pre-commit = "^4.0"` to dev deps and switch to `poetry run pre-commit install`
4. Replace `@declared_attr __tablename__` on abstract ORM bases with explicit declarations per concrete class
5. Review any `is_configured()` usage — each case needs ADR justification or conversion to required settings

---

## v0.4.2

### Summary

Unified DI construction pattern across all service types, added mechanical enforcement for architectural layer boundaries (pyright + import-linter), standardised structured JSON logging for production, and formalised the local developer workflow via Makefile.

### Changes by file

#### `dependency-injection.mdc` — Breaking

- **Removed** `get_instance()` singleton pattern from infra service classes. The `injector` container with `scope=singleton` is now the single singleton contract for all service types.
- **Unified** `@inject` on `__init__` for both infra and business services — one DI style across the codebase.
- **Added** "Design principle" section explaining why one style applies to all entry points (HTTP, worker, CLI).
- **Added** "Entry points" section showing the same `configure_container()` call works for all process types.
- **Updated** DI module bindings — `binder.bind(PostgresService, scope=singleton)` replaces `binder.bind(PostgresService, to=PostgresService.get_instance(), scope=singleton)`.
- **Updated** settings pattern — `AppSettings` is now injected via DI into service constructors; `FooSettings.get_instance()` is retained only for bootstrap (ConfigModule binding).

#### `infra-services.mdc` — Breaking

- **Added** "Construction" section: infra services use `@inject` on `__init__`; `get_instance()` class methods must be removed from infra service classes.
- **Updated** settings section: settings received via `@inject`, not pulled with `get_instance()` inside `__init__`.

#### `python-tooling.mdc` — Additive

- **Added** pyright as the static type checker with `pyproject.toml` config. Existing services: `basic` mode. New services: `strict` from day one.
- **Added** import-linter with canonical `.importlinter` layer contract enforcing `src.api → src.business_services → src.database.*.repository → src.database.*.schema`.
- **Added** Makefile with `check` target (`format`, `lint`, `types`, `layers`) as the canonical local developer workflow.
- **Added** pre-commit configuration including pyright and import-linter hooks.
- **Added** enforcement table distinguishing what import-linter covers (import boundaries) vs what pyright covers (type signatures at call sites).

#### `strong-typing.mdc` — Additive

- **Added** pyright as the named enforcer in the quality bar section — links to `python-tooling.mdc` for configuration.

#### `architecture.mdc` — Additive

- **Added** enforcement table in "API layering" section — maps each layer boundary constraint to the tool that enforces it (import-linter or pyright).

#### `repository-pattern.mdc` — Additive

- **Updated** layer diagram to use full package paths (`src.api`, `src.business_services`, etc.) matching the `.importlinter` contract.
- **Added** "Enforcement" table mapping each layering constraint to its tool (import-linter / pyright).

#### `pydantic-schemas.mdc` — Additive

- **Added** enforcement note under "Where models live" — explains how the import-linter contract and pyright together enforce the "no Pydantic models in `src/api/`" constraint.

#### `logging-loguru.mdc` — Additive

- **Added** "Output format — structured JSON in production" section: production deployments must emit structured JSON; local dev uses text. Driven by `LOG_FORMAT` env var in `setup_logging()`.
- **Added** minimum required fields for structured logs: `service`, `environment`, `correlation_id`, `level`, `message`, `timestamp`.
- **Updated** message style: structured fields passed as keyword arguments to log calls, not embedded in the message string.
- **Updated** correlation section: `correlation_id` must appear as a top-level JSON field, not embedded in the message string.

### Migration guide: 0.2.x → 0.4.0

#### Breaking: remove `get_instance()` from infra service classes

**Before (0.2.x):**
```python
class PostgresService(BaseInfraService):
    _instance: Optional["PostgresService"] = None

    @classmethod
    def get_instance(cls) -> "PostgresService":
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def __init__(self) -> None:
        super().__init__()
        self._settings = AppSettings.get_instance()
```

**After (0.3.0):**
```python
from injector import inject

class PostgresService(BaseInfraService):
    @inject
    def __init__(self, settings: AppSettings) -> None:
        super().__init__()
        self._settings = settings
```

**DI module binding before:**
```python
binder.bind(PostgresService, to=PostgresService.get_instance(), scope=singleton)
```

**DI module binding after:**
```python
binder.bind(PostgresService, scope=singleton)
```

**Startup loop before:**
```python
postgres = PostgresService.get_instance()
await postgres.initialize()
```

**Startup loop after:**
```python
postgres = injector.get(PostgresService)
await postgres.initialize()
```

The `async initialize()` / `async close()` / `health_check()` lifecycle on `BaseInfraService` is **unchanged**.

#### Additive: new tooling to add to each consumer repo

1. `poetry add --group dev pyright import-linter`
2. Add `[tool.pyright]` section to `pyproject.toml`
3. Add `.importlinter` at repo root (adapt layer paths per service)
4. Add `Makefile` with `check` target
5. Add `.pre-commit-config.yaml` with all four hooks
6. Run `pre-commit install`

#### Additive: structured logging

Update `setup_logging()` in `src/logging/` to switch between JSON and text output based on `LOG_FORMAT` env var. See `logging-loguru.mdc` for the guidance. Existing `logger.info(...)` call sites are unchanged.

---

## v0.2.0

### Summary

Restructured repo layout so the root of this repo can be mounted directly as `.cursor/rules/` in consumer repos via git submodule. Removed the legacy copy/install mechanism.

### Changes

- Moved all `.mdc` rule modules from `cursor/rules/` to the repository root.
- Removed the legacy copy/install mechanism.
- Updated consumer adoption workflow from copy-based to submodule-based.
- Added service profile classification (internal provider vs internal consumer only).
- Added JWT verification pattern standardised across non-issuer services.
- Added `docs/specification/` pointer separating product docs from shared rules.

### Migration guide: 0.1.x → 0.2.0

Remove `python-services-rules/` from the consumer repo root (old copy location). Remove or untrack `.cursor/rules/` if it was previously gitignored. Then follow the first-time submodule setup in the README.

---

## v0.1.x

Initial rules extracted from an internal Python HTTP service. Distributed via a copy/install script into `cursor/rules/` at the consumer root.
