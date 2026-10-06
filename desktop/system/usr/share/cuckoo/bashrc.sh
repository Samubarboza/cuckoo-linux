# shellcheck shell=bash
# Bash settings for Cuckoo Linux: the Starship prompt and the Atuin history.

# Atuin needs bash-preexec to see each command
if [[ -r /usr/share/bash-preexec/bash-preexec.sh ]]; then
  # shellcheck source=/dev/null
  source /usr/share/bash-preexec/bash-preexec.sh
fi

if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

if command -v atuin &>/dev/null; then
  eval "$(atuin init bash)"
fi
