# python-services-rules

**Open constitution for Python microservices** — shared Cursor agent rules (`.mdc`)
for FastAPI services: layered architecture, dependency injection, repositories,
logging, tooling, and spec-driven delivery.

Rules describe **how to code**. They do **not** contain product requirements,
route catalogs, or environment-specific URLs — those live in each consumer repo
under `docs/specification/`.

| | |
|---|---|
| **License** | [MIT](LICENSE) |
| **Version** | see [`VERSION`](VERSION) (currently **0.5.9**) · [CHANGELOG](CHANGELOG.md) |
| **Mount path** | `.cursor/rules/` (git submodule) |
| **Scaffold** | [python-fastapi-foundation](https://github.com/drivestream-lab/python-fastapi-foundation) — optional cookiecutter for new services |

---

## Layout

This repository root **is** the contents of a consumer's `.cursor/rules/` directory:

```text
python-services-rules/
  VERSION
  README.md
  CHANGELOG.md
  code-guidelines-index.mdc    ← module index (start here)
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

Full module table: [`code-guidelines-index.mdc`](code-guidelines-index.mdc).

---

## Adoption

From the **consumer service repo root**:

```bash
rm -rf .cursor/rules

git submodule add https://github.com/<org>/python-services-rules.git .cursor/rules
cd .cursor/rules && git checkout v0.5.9 && cd ../..

git add .gitmodules .cursor/rules
git commit -m "Add Python service Cursor rules at .cursor/rules (v0.5.9)"
```

Cursor loads **`.cursor/rules/*.mdc`** automatically — no copy step.

Greenfield services may start from
[python-fastapi-foundation](https://github.com/drivestream-lab/python-fastapi-foundation)
(`cookiecutter … --checkout v0.3.2`), then add the rules submodule as above.

---

## Tooling expected by the rules

`python-tooling.mdc` defines required quality gates: **Black**, **Ruff**,
**pyright**, **import-linter**, **pre-commit**, and Makefile targets
(`setup`, `check`, `test`). Exact config files live in the consumer repo or
scaffold — not in this constitution.

---

## Bump rules version

```bash
cd .cursor/rules
git fetch --tags
git checkout v0.5.9    # target version
cd ../..
git add .cursor/rules
git commit -m "Bump Python service rules to v0.5.9"
```

Read [CHANGELOG](CHANGELOG.md) before every bump. **Breaking** releases require
consumer code changes before or alongside the submodule pointer update.

---

## Governance

| Principle | Detail |
|-----------|--------|
| **Ownership** | Platform / architecture team owns this repo |
| **Consumers** | Pin a release tag — never fork or edit rules in product repos |
| **Changes** | Propose via PR here; consumers update the submodule pointer only |
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

---

## Release process (maintainers)

1. Branch `rules/<short-description>` — edit `*.mdc` at repo root; peer review required
2. Bump **`VERSION`** (semver) and **`CHANGELOG.md`**
3. Update version in this README header
4. PR → `develop` → `main`; tag and push:

```bash
git tag v0.5.9
git push origin v0.5.9
```

---

## Migration from 0.1.x layout

**0.1.x** used copied rules under `cursor/rules/`. **0.2.0+** mounts this repo at
**`.cursor/rules`** via submodule. Remove legacy copied directories when upgrading.

---

## Related repositories

| Repo | Role |
|------|------|
| [python-fastapi-foundation](https://github.com/drivestream-lab/python-fastapi-foundation) | Cookiecutter scaffold for new FastAPI services |
| [nextjs-bff-rules](https://github.com/drivestream-lab/nextjs-bff-rules) | Constitution for BFF portals that call Python APIs |

---

## License

MIT — see [LICENSE](LICENSE).
