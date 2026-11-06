# brew-secure interactive snippet — source from ~/.zshrc / ~/.bashrc
# Runs the vulnerability report on interactive TTY startup.

if [ -n "${PS1:-}" ] && [ -t 1 ] && [ -x "${HOME}/bin/brew-secure" ]; then
  "${HOME}/bin/brew-secure" --startup
fi
