map \] :!osascript -e 'tell application "Google Chrome"' -e 'tell active tab of first window' -e 'execute javascript "window.location.reload()"' -e 'end tell' -e 'end tell'<CR><CR>
