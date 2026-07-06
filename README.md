# python-services-rules

**Open constitution for Python microservices** — shared Cursor agent rules (`.mdc`) for FastAPI services: layered architecture, dependency injection, repositories, logging, tooling, and spec-driven delivery.

Rules describe **how to code**. They do **not** contain product requirements, route catalogs, or environment-specific URLs — those live in each consumer repo under `docs/specification/`.

| | |
|---|---|
| **License** | [MIT](LICENSE) |
| **Version** | see [`VERSION`](VERSION) (currently **0.5.5**) · [CHANGELOG](CHANGELOG.md) |
| **Harness profile** | `python-backend` |
| **Mount path** | `.cursor/rules/` (git submodule) |
| **Pairs with** | [python-fastapi-foundation](https://github.com/drivestream-lab/python-fastapi-foundation) · [prayog-skills](https://github.com/drivestream-lab/prayog-skills) · [launchpad](https://github.com/drivestream-lab/launchpad) |

---

## Role in the harness stack

```text
.harness-pin.yaml  (profile: python-backend)
        │
        ├── rules  ──►  python-services-rules  →  .cursor/rules/*.mdc
        └── agent_skills  ──►  prayog-skills  →  .agents/skills/ (seeded)
```

[Launchpad](https://github.com/drivestream-lab/launchpad) `sync-harness-app` writes the pin, syncs this submodule, and seeds dev skills. See [harness pins](https://github.com/drivestream-lab/launchpad/blob/main/playbook/harness-pins.md).

Greenfield services: start from [python-fastapi-foundation](https://github.com/drivestream-lab/python-fastapi-foundation) — it generates `.gitmodules` pointing here.

---

## Layout

This repository root **is** the contents of a consumer's `.cursor/rules/` directory:

```text
python-services-rules/
  VERSION
  README.md
  CHANGELOG.md
  code-guidelines-index.mdc    ← module index
  architecture.mdc
  dependency-injection.mdc
  repository-pattern.mdc
  pydantic-schemas.mdc
  logging-loguru.mdc
  python-tooling.mdc
  spec-driven-development.mdc
  testing-verify-flows.mdc
  …
```

---

## Adoption

### With Launchpad (recommended)

```bash
launchpad sync-harness-app --repo <service> --apply
launchpad verify-harness-app --repo <service>
```

### Manual submodule

From the **consumer service repo root**:

```bash
rm -rf .cursor/rules

git submodule add https://github.com/drivestream-lab/python-services-rules.git .cursor/rules
cd .cursor/rules && git checkout v0.5.5 && cd ../..

git add .gitmodules .cursor/rules
git commit -m "Add Python service Cursor rules at .cursor/rules (v0.5.5)"
```

Cursor loads **`.cursor/rules/*.mdc`** automatically — no copy step.

### AGENTS.md

Point agents at the rules boundary and product docs. Use your tenant `templates/AGENTS.python.md` or harness sync output. Minimum contract:

- Do **not** edit `.cursor/rules/` in the consumer — propose changes via PR on this repo
- Product specs: `docs/specification/product/`, ADRs, as-built, `tests/README.md`

---

## Tooling expected by the rules

`python-tooling.mdc` requires quality gates in each consumer. After pinning, ensure the service repo has:

```bash
poetry add --group dev pyright import-linter
```

**`Makefile`** (typical targets):

```makefile
.PHONY: check format lint types layers test

check: format lint types layers

format:
	poetry run black --check --line-length 100 src/ tests/

lint:
	poetry run ruff check src/ tests/

types:
	poetry run pyright

layers:
	poetry run lint-imports

test:
	poetry run pytest
```

**`.importlinter`** — layer contract (adapt packages to your layout):

```ini
[importlinter]
root_packages = src

[importlinter:contract:layer-architecture]
name = Layered architecture
type = layers
layers =
    src.api
    src.business_services
    src.database.postgres.repository
    src.database.postgres.schema
```

[python-fastapi-foundation](https://github.com/drivestream-lab/python-fastapi-foundation) generates these files for new services.

---

## Bump rules version

```bash
cd .cursor/rules
git fetch --tags
git checkout v0.5.5    # target version
cd ../..
git add .cursor/rules .harness-pin.yaml
git commit -m "Bump Python service rules to v0.5.5"
```

Read [CHANGELOG](CHANGELOG.md) before every bump. **Breaking** releases require consumer code changes before or alongside the pointer update.

---

## Governance

| Principle | Detail |
|-----------|--------|
| **Ownership** | Platform / architecture team owns this repo |
| **Consumers** | Pin a release tag — never fork or edit rules in product repos |
| **Changes** | PR here → semver tag → bump harness approved pairs in tenant config |
| **Product truth** | Requirements, ADRs, as-built → `docs/specification/` per service |
| **Do not** | `gitignore` `.cursor/rules` in consumers — breaks the pinned submodule |

---

## What stays in each service repo

| Path | Purpose |
|------|---------|
| `docs/specification/product/` | Requirements, capabilities, features |
| `docs/specification/adr/` | Architecture decision records |
| `docs/specification/as-built/` | What is live today |
| `README.md`, `tests/README.md` | Setup, env vars, verify commands |
| `AGENTS.md` | Agent router and harness pin |

---

## Rule index

See [`code-guidelines-index.mdc`](code-guidelines-index.mdc) for the full module table covering architecture, DI, repos, HTTP conventions, migrations, SDD, verify flows, and tooling.

---

## Release process (maintainers)

1. Branch `rules/<short-description>` — edit `*.mdc` at repo root; peer review required
2. Bump **`VERSION`** (semver):
   - **PATCH** — clarifications, non-breaking additions
   - **MINOR** — new guidance sections, additive tooling
   - **MAJOR** — breaking consumer changes (document migration in CHANGELOG)
3. Update version in this README and [CHANGELOG](CHANGELOG.md)
4. PR → `develop` → `main`; tag and push:

```bash
git tag v0.5.5
git push origin v0.5.5
```

5. Update tenant `config/harness-<org>.yaml` approved `rules` + `agent_skills` pairs; notify service teams

---

## Migration from 0.1.x layout

**0.1.x** used copied rules under `cursor/rules/`. **0.2.0+** mounts this repo at **`.cursor/rules`** via submodule. Remove legacy copied directories when upgrading.

---

## Related repositories

| Repo | Role |
|------|------|
| [python-fastapi-foundation](https://github.com/drivestream-lab/python-fastapi-foundation) | Cookiecutter scaffold implementing these rules |
| [data-platform-rules](https://github.com/drivestream-lab/data-platform-rules) | Flink/Java constitution — not for Python APIs |
| [prayog-skills](https://github.com/drivestream-lab/prayog-skills) | SDD agent workflows |
| [launchpad](https://github.com/drivestream-lab/launchpad) | Factory CLI and playbook |

---

## License

MIT — see [LICENSE](LICENSE).
