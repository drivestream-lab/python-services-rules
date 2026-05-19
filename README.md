# python-services-rules

Shared **Cursor agent rules** (`.mdc`) for DriveStream Python HTTP services. Rules describe **how to code** (architecture, DI, repos, HTTP conventions)—not product requirements.

**Source of truth:** evolved from **Abhilekh** `.cursor/rules/`, with cross-cutting additions (service profiles, JWT verification, `docs/specification/` pointers).

**Version:** see [`VERSION`](VERSION) (currently **0.1.0**).

## Layout

```
python-services-rules/
  VERSION
  README.md
  cursor/rules/*.mdc      # 14 architectural rule modules
  scripts/
    install_cursor_rules.sh
```

## Adopt in a service repo (submodule)

From the consumer repo root (e.g. `airforge/`):

```bash
git submodule add <remote-url> python-services-rules
./python-services-rules/scripts/install_cursor_rules.sh
```

Pin the submodule commit in the consumer **README** (e.g. `python-services-rules @ 0.1.0`).

### Re-install after bumping the submodule

```bash
git submodule update --remote python-services-rules   # optional: pull latest
./python-services-rules/scripts/install_cursor_rules.sh --force
```

### Symlink instead of copy (optional)

```bash
./python-services-rules/scripts/install_cursor_rules.sh --link
```

Cursor reads **`.cursor/rules/`** at the consumer repo root; the install script copies or links from this package.

## What stays in each service repo

| Location | Purpose |
|----------|---------|
| **`docs/specification/product/`** | Requirements, capabilities |
| **`docs/specification/adr/`** | ADRs |
| **`README.md`**, **`tests/README.md`** | Setup, env, verify commands |
| **`AGENTS.md`** (recommended) | Router: point agents to rules + product docs |

Do **not** put product-specific behavior in shared `.mdc` files.

## Rule index

See [`cursor/rules/code-guidelines-index.mdc`](cursor/rules/code-guidelines-index.mdc).

## Reference implementations

- **Abhilekh** — layered shell, DI lifecycle, internal provider API
- **Parichay** — JWT issuance and claim shapes
- **Airforge** — internal consumer only (no inbound `api/internal/`)

## Contributing

1. Change rules in **`cursor/rules/`**.
2. Bump **`VERSION`** (semver).
3. Consumer repos: update submodule + run **`install_cursor_rules.sh --force`**.
