function unquarantine --wraps 'xattr -d com.apple.quarantine' --description 'Remove the macOS com.apple.quarantine attribute (Gatekeeper "downloaded from internet" flag)'
    if test (count $argv) -eq 0
        echo "usage: unquarantine FILE [FILE...]" >&2
        return 2
    end
    xattr -d com.apple.quarantine $argv
end
