# brew-secure login snippet — source from ~/.zprofile / ~/.bash_profile
# Sets up Homebrew, ~/bin on PATH, and secure Homebrew env vars.

if [ -x /opt/homebrew/bin/brew ]; then
  _brew_bin=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
  _brew_bin=/usr/local/bin/brew
else
  _brew_bin=
fi

if [ -n "${_brew_bin}" ]; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$("${_brew_bin}" shellenv zsh)"
  else
    eval "$("${_brew_bin}" shellenv bash)"
  fi
fi
unset _brew_bin

case ":${PATH}:" in
  *":${HOME}/bin:"*) ;;
  *) export PATH="${HOME}/bin:${PATH}" ;;
esac

if [ -f "${HOME}/.config/homebrew/secure.env" ]; then
  # shellcheck disable=SC1091
  . "${HOME}/.config/homebrew/secure.env"
fi
