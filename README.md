# python-services-rules

Shared **Cursor agent rules** (`.mdc`) for DriveStream Python HTTP services. Rules describe **how to code** (architecture, DI, repos, HTTP conventions)—not product requirements.

**Source of truth:** evolved from **Abhilekh** `.cursor/rules/`, with cross-cutting additions (service profiles, JWT verification, `docs/specification/` pointers).

**Version:** see [`VERSION`](VERSION) (currently **0.2.0**).

## Layout

This repository root **is** the contents of a consumer's **`.cursor/rules/`** directory:

```
python-services-rules/     # mount as .cursor/rules in service repos
  VERSION
  README.md
  architecture.mdc
  dependency-injection.mdc
  ... (14 rule modules)
```

## Adopt in a service repo (git submodule)

From the consumer repo root (e.g. `airforge/`):

```bash
# Remove any copied rules first
rm -rf .cursor/rules

git submodule add https://github.com/autrio10x/python-services-rules.git .cursor/rules
cd .cursor/rules && git checkout v0.2.0 && cd ../..
git add .gitmodules .cursor/rules
git commit -m "Pin shared Python service Cursor rules at .cursor/rules"
```

Cursor reads **`.cursor/rules/*.mdc`** directly—no install script.

### Bump rules version

```bash
cd .cursor/rules
git fetch --tags
git checkout v0.3.0
cd ../..
git add .cursor/rules
git commit -m "Bump shared Cursor rules to v0.3.0"
```

Pin the tag or commit SHA in the consumer **README** and **`AGENTS.md`**.

## Governance

- **Architecture team** owns this repo; service teams **do not** edit rules in product repos.
- Propose rule changes via PR here; consumers only update the submodule pointer.
- **Do not** `gitignore` `.cursor/rules` in consumers—that breaks the pinned submodule for the team.

## What stays in each service repo

| Location | Purpose |
|----------|---------|
| **`docs/specification/product/`** | Requirements, capabilities |
| **`docs/specification/adr/`** | ADRs |
| **`README.md`**, **`tests/README.md`** | Setup, env, verify commands |
| **`AGENTS.md`** (recommended) | Router: do not edit `.cursor/rules`; link product docs |

Do **not** put product-specific behavior in shared `.mdc` files.

## Rule index

See [`code-guidelines-index.mdc`](code-guidelines-index.mdc).

## Reference implementations

- **Abhilekh** — layered shell, DI lifecycle, internal provider API
- **Parichay** — JWT issuance and claim shapes
- **Airforge** — internal consumer only (no inbound `api/internal/`)

## Contributing

1. Edit **`*.mdc`** at this repo root.
2. Bump **`VERSION`** (semver) and tag (e.g. `git tag v0.2.0`).
3. Consumer repos: update submodule commit only—no copy/install step.

## Migration from 0.1.x

**0.1.x** used `cursor/rules/*.mdc` and optional `scripts/install_cursor_rules.sh`. **0.2.0+** mounts this repo at **`.cursor/rules`**; remove `python-services-rules/` at consumer root if you used the old layout.
