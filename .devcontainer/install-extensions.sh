#!/usr/bin/env bash
set -u

# Instala extensiones para VS Code / code-server si está disponible.
# No falla el script si no se encuentra un CLI; imprime instrucciones útiles.

EXTENSIONS=(
  "tamasfe.even-better-toml"
  "davidanson.vscode-markdownlint"
  "budparr.language-hugo-vscode"
)

echo "Installing VS Code extensions if a CLI is available..."

install_bin=""
install_arg="--install-extension"
if command -v code-server >/dev/null 2>&1; then
  install_bin="code-server"
elif command -v code >/dev/null 2>&1; then
  install_bin="code"
else
  # Fallback: try to find a code-server remote-cli binary in /tmp (common for code-server installs)
  cli_path=$(find /tmp -maxdepth 12 -type f -name code-server -path "*remote-cli/*" -perm /111 -print -quit 2>/dev/null || true)
  if [ -n "$cli_path" ]; then
    install_bin="$cli_path"
  fi
fi

if [ -z "$install_bin" ]; then
  echo "No 'code' or 'code-server' CLI found. Skipping automatic extension install."
  echo "To install manually, run one of these commands on the host/container with the appropriate CLI:"
  echo "  code --install-extension <publisher.extension>"
  echo "  code-server --install-extension <publisher.extension>"
  exit 0
fi

for ext in "${EXTENSIONS[@]}"; do
  echo "Installing extension: $ext"
  if "$install_bin" "$install_arg" "$ext"; then
    echo "  -> $ext installed"
  else
    echo "  -> Failed to install $ext (continuing)"
  fi
done

echo "Extensions installation finished."
