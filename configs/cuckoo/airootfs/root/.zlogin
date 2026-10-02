# fix for screen readers
if grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

~/.automated_script.sh

# Start the installer on the main screen. Screen reader users keep the console,
# and leaving the installer also drops back to the console.
if [[ "$(tty)" == /dev/tty1 ]] && ! grep -Fqa 'accessibility=' /proc/cmdline &> /dev/null; then
    # Bigger console font so the logo and the installer read larger
    setfont ter-v32n 2> /dev/null || true
    cuckoo-configurator || true
fi
