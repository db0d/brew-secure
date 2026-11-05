#!/usr/bin/env bash
# Install brew-secure into the current user's home directory.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/bin"
CONFIG_DIR="${HOME}/.config/homebrew"
SHELL_DIR="${CONFIG_DIR}/shell"
MARKER_BEGIN="# >>> brew-secure >>>"
MARKER_END="# <<< brew-secure <<<"

log() { printf '%s\n' "$*"; }

install_file() {
  local src="$1" dest="$2" mode="${3:-644}"
  mkdir -p "$(dirname "${dest}")"
  cp "${src}" "${dest}"
  chmod "${mode}" "${dest}"
  log "Installed ${dest}"
}

upsert_profile_block() {
  local profile="$1" block_file="$2"
  local tmp
  mkdir -p "$(dirname "${profile}")"

  if [[ ! -f "${profile}" ]]; then
    cat "${block_file}" >"${profile}"
    log "Created ${profile}"
    return 0
  fi

  tmp="$(mktemp)"
  if grep -qF "${MARKER_BEGIN}" "${profile}"; then
    # Strip the old managed block, then append the current one.
    awk -v begin="${MARKER_BEGIN}" -v end="${MARKER_END}" '
      $0 == begin { skip=1; next }
      $0 == end { skip=0; next }
      !skip { print }
    ' "${profile}" >"${tmp}"
    # Drop trailing blank lines so reinstalls stay tidy.
    while [[ -s "${tmp}" ]] && [[ -z "$(tail -n1 "${tmp}")" ]]; do
      sed -i '' -e '$d' "${tmp}"
    done
    {
      cat "${tmp}"
      printf '\n'
      cat "${block_file}"
    } >"${profile}"
    rm -f "${tmp}"
    log "Updated brew-secure block in ${profile}"
  else
    {
      cat "${profile}"
      printf '\n'
      cat "${block_file}"
    } >"${tmp}"
    mv "${tmp}" "${profile}"
    log "Appended brew-secure block to ${profile}"
  fi
}

main() {
  log "Installing brew-secure from ${ROOT}"

  install_file "${ROOT}/bin/brew-secure" "${BIN_DIR}/brew-secure" 755
  install_file "${ROOT}/config/secure.env" "${CONFIG_DIR}/secure.env" 644
  install_file "${ROOT}/shell/login.sh" "${SHELL_DIR}/login.sh" 644
  install_file "${ROOT}/shell/interactive.sh" "${SHELL_DIR}/interactive.sh" 644

  upsert_profile_block "${HOME}/.zprofile" "${ROOT}/shell/zprofile"
  upsert_profile_block "${HOME}/.zshrc" "${ROOT}/shell/zshrc"
  upsert_profile_block "${HOME}/.bash_profile" "${ROOT}/shell/bash_profile"
  upsert_profile_block "${HOME}/.bashrc" "${ROOT}/shell/bashrc"

  log ""
  log "Done. Open a new terminal, or run: brew-secure"
  log "Skip startup checks with: BREW_SECURE_SKIP=1"
}

main "$@"
