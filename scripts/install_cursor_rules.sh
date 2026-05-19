#!/usr/bin/env bash
# Install shared Cursor rules into a consumer Python service repo.
#
# Usage (from consumer repo root, e.g. airforge/):
#   ./python-services-rules/scripts/install_cursor_rules.sh
#   ./python-services-rules/scripts/install_cursor_rules.sh --link
#
# Options:
#   --link   Symlink rules instead of copying (default: copy)
#   --force  Replace existing .cursor/rules/*.mdc files

set -euo pipefail

LINK_MODE=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --link) LINK_MODE=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      echo "Usage: $0 [--link] [--force]"
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_SRC="${SCRIPT_DIR}/../cursor/rules"

# Consumer repo root: parent of python-services-rules/ when used as submodule
if [[ -d "${SCRIPT_DIR}/../../.git" ]]; then
  CONSUMER_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
else
  CONSUMER_ROOT="$(pwd)"
fi

DEST="${CONSUMER_ROOT}/.cursor/rules"

if [[ ! -d "${RULES_SRC}" ]]; then
  echo "[ERROR] Rules source not found: ${RULES_SRC}" >&2
  exit 1
fi

mkdir -p "${DEST}"

shopt -s nullglob
mdc_files=("${RULES_SRC}"/*.mdc)
if [[ ${#mdc_files[@]} -eq 0 ]]; then
  echo "[ERROR] No .mdc files in ${RULES_SRC}" >&2
  exit 1
fi

VERSION_FILE="${SCRIPT_DIR}/../VERSION"
if [[ -f "${VERSION_FILE}" ]]; then
  echo "[INFO] python-services-rules version: $(tr -d '[:space:]' < "${VERSION_FILE}")"
fi

for src in "${mdc_files[@]}"; do
  name="$(basename "${src}")"
  target="${DEST}/${name}"

  if [[ -e "${target}" && "${FORCE}" -eq 0 ]]; then
    if [[ -L "${target}" ]]; then
      existing="$(readlink "${target}")"
      if [[ "${existing}" == "${src}" ]]; then
        echo "[OK] Already linked: ${name}"
        continue
      fi
    elif cmp -s "${src}" "${target}" 2>/dev/null; then
      echo "[OK] Already up to date: ${name}"
      continue
    fi
  fi

  if [[ "${LINK_MODE}" -eq 1 ]]; then
    ln -sfn "${src}" "${target}"
    echo "[OK] Linked ${name}"
  else
    cp "${src}" "${target}"
    echo "[OK] Copied ${name}"
  fi
done

echo "[OK] Installed $((${#mdc_files[@]})) rule(s) to ${DEST}"
