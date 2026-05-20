# Changelog

All notable changes to `python-services-rules` are documented here.

Format: **Breaking** changes require code changes in consumer repos before or alongside the version bump. **Additive** changes are safe to adopt incrementally.

---

## v0.4.0

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
