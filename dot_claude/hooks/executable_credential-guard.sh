#!/usr/bin/env bash
# PreToolUse hook: block credential-store access; require explicit authorization.
# Exit 0 = allow. Exit 2 = block (stdout shown to Claude as system message).

set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$command" ] && exit 0

# Each pattern is a case-insensitive substring matched against the full command
# string via `grep -qi`. A match triggers an exit-2 hard block before the user
# permission prompt is ever shown. Patterns must be specific enough to avoid
# false positives but broad enough to catch common invocation styles.
patterns=(
  # --- 1Password CLI (op) ---
  "op item get"       # Fetches full item details from a 1Password vault, including passwords, usernames, and all custom field values
  "op item list"      # Enumerates items in a 1Password vault, revealing the names and types of stored secrets
  "op item ls"        # Alias for `op item list` — same enumeration risk
  "op read"           # Reads a secret directly by reference URI (e.g., op://vault/item/field), returning the raw secret value
  "op run"            # Executes a subprocess with 1Password secrets injected as environment variables, exposing them to the child process
  "op inject"         # Reads a config file template and replaces secret reference placeholders with live values, writing secrets to a file
  "op document get"   # Downloads a document (e.g., SSH key, cert bundle, secrets file) stored in a 1Password vault

  # --- macOS Keychain (security) ---
  "security find-generic-password"   # Searches macOS Keychain for generic (non-web) passwords; -g/-w flags print the password in plaintext
  "security find-internet-password"  # Searches macOS Keychain for internet/website passwords; -g flag prints the password in plaintext
  "security find-certificate"        # Searches macOS Keychain for certificates; -p exports in PEM format (conservative: certs are public-key material)
  "security find-identity"           # Finds identities (certificate + private key pair); reveals which private keys exist; used for code-signing access
  "security find-key"                # Finds cryptographic keys in the keychain (symmetric and asymmetric); can expose key metadata
  "security export"                  # Exports keychain items; -t privKeys or -t identities exports private key material (PKCS#12/PEM)
  "security dump-keychain"           # Dumps all items in a keychain; with -d flag, decrypts and prints plaintext data for every item — most dangerous security subcommand

  # --- GPG ---
  "gpg -d"             # Decrypts a GPG-encrypted file or stdin (short form of --decrypt); no trailing space so it catches `gpg -d file` and combined flags like `gpg -qd`
  "gpg --decrypt"      # Decrypts a GPG-encrypted file or stdin using the available secret key (long form of -d)
  "gpg --export-secret" # Matches --export-secret-keys and --export-secret-subkeys; exports private key material from the GPG keyring
  "gpg --export-ssh-key" # Exports a GPG authentication subkey in OpenSSH public key format; reveals key material
  "gpg --list-secret-keys" # Lists all secret keys available in the keyring — enumeration step before export
  "gpg -K"             # Short form of --list-secret-keys; lists secret keys in the keyring
)

block_command() {
  local pattern="$1"
  local command="$2"
  cat <<EOF
CREDENTIAL ACCESS BLOCKED

Pattern detected: "$pattern"
Command: $command

This command accesses a credential store. To authorize it, ask me to run the
command and approve the dialog that appears, or run the command yourself in
your terminal.
EOF
  exit 2
}

for pattern in "${patterns[@]}"; do
  if echo "$command" | grep -qi "$pattern"; then

    # Truncate long commands for display in the dialog
    display_cmd="${command:0:200}"
    [ "${#command}" -gt 200 ] && display_cmd="${display_cmd}…"

    # Fallback to hard block if osascript is not available (non-macOS)
    if ! command -v osascript &>/dev/null; then
      block_command "$pattern" "$command"
    fi

    # Write AppleScript to a temp file to avoid quoting issues with arbitrary
    # command strings. Replace double-quotes with single-quotes in display text.
    safe_pattern="${pattern//\"/\'}"
    safe_cmd="${display_cmd//\"/\'}"

    tmpscript=$(mktemp /tmp/credential-guard-XXXXXX.scpt)
    cat > "$tmpscript" <<SCPT
display dialog "Approve credential access?" & return & return & "Pattern: ${safe_pattern}" & return & "Command:" & return & "${safe_cmd}" buttons {"Block", "Allow"} default button "Block" with title "credential-guard" giving up after 10
return button returned of result
SCPT

    result=$(osascript "$tmpscript" 2>/dev/null || echo "Block")
    rm -f "$tmpscript"

    if [ "$result" = "Allow" ]; then
      exit 0
    fi

    block_command "$pattern" "$command"
  fi
done

exit 0
