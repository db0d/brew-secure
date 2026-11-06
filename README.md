# brew-secure

Hardens your Homebrew environment and reports vulnerability counts from `brew vulns` when you open a terminal (or when you run the script by hand).

## What it does

1. **Applies secure Homebrew settings** on shell login:
   - `HOMEBREW_NO_INSECURE_REDIRECT=1` — block HTTPS→HTTP redirects
   - `HOMEBREW_NO_ANALYTICS=1` — disable analytics
   - `HOMEBREW_FORBID_PACKAGES_FROM_PATHS=1` — refuse path-based formula/cask installs
   - `HOMEBREW_CASK_OPTS=… --require-sha` — require cask checksums
   - `HOMEBREW_VERIFY_ATTESTATIONS=1` — verify bottle attestations (may install `gh`)
2. **Checks integrity** of the Homebrew prefix ownership and official git origin.
3. **Updates Homebrew** (`brew update`) so brew itself stays current.
4. **Scans installed formulae** with `brew vulns --json` and reports Critical / High / Medium / Low counts.
5. **Remediates by severity**:
   - Critical / High → runs `brew upgrade` automatically
   - Medium / Low → prompts whether to run `brew upgrade`
   - No findings → no prompt

> Note: `brew vulns` covers formulae, not casks. Homebrew itself is kept current via `brew update`.

## Requirements

- Homebrew 7+ (`brew vulns`)
- `jq` (macOS ships it; otherwise `brew install jq`)
- Interactive TTY for the upgrade prompt

## Install

From this repository:

```bash
./install.sh
```

That installs:

| Destination | Purpose |
|---|---|
| `~/bin/brew-secure` | Main script |
| `~/.config/homebrew/secure.env` | Secure env exports |
| `~/.config/homebrew/shell/*.sh` | Shared login / interactive snippets |
| `~/.zprofile`, `~/.zshrc` | zsh hooks |
| `~/.bash_profile`, `~/.bashrc` | bash hooks |

Managed profile sections are wrapped in `# >>> brew-secure >>>` / `# <<< brew-secure <<<` markers so re-running `./install.sh` updates them safely.

## Usage

```bash
brew-secure              # full check + upgrade prompt
brew-secure --startup    # same; used by shell startup hooks
brew-secure --force      # ignore the startup cache
brew-secure --apply-only # only apply secure env + integrity checks
brew-secure --scan-only  # scan and report counts, no upgrade prompt
```

### Environment knobs

| Variable | Effect |
|---|---|
| `BREW_SECURE_SKIP=1` | Skip startup hook entirely |
| `BREW_SECURE_CACHE_SECS=3600` | Startup cache TTL (default 1 hour) |
| `BREW_SECURE_NO_UPDATE=1` | Skip `brew update` before scanning |
| `BREW_SECURE_NO_PROMPT=1` | Skip remediation (no auto-upgrade, no prompt) |

## Repository layout

```
bin/brew-secure          # scanner + hardening script
config/secure.env        # secure Homebrew exports
shell/login.sh           # brew shellenv + PATH + secure.env
shell/interactive.sh     # startup vulns report
shell/{zprofile,zshrc,bash_profile,bashrc}
install.sh               # install / refresh into $HOME
```

## Updating

Pull or edit this repo, then re-run:

```bash
./install.sh
```

## References

- [Homebrew Vulnerability Management](https://docs.brew.sh/Homebrew-Vulnerability-Management)
- [Homebrew Security and Supply Chain](https://docs.brew.sh/Homebrew-Security-and-Supply-Chain)
- [Homebrew environment variables](https://docs.brew.sh/Manpage#environment)
