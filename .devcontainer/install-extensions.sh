#!/usr/bin/env bash
set -euo pipefail

# Open VSX registry — requerido porque code-server no puede usar el marketplace de Microsoft
export SERVICE_URL=https://open-vsx.org/vscode/gallery
export ITEM_URL=https://open-vsx.org/vscode/item

# Extensiones disponibles en Open VSX
EXTENSIONS=(
  "tamasfe.even-better-toml"
  "davidanson.vscode-markdownlint"
  "budparr.language-hugo-vscode"
)

if ! command -v code-server >/dev/null 2>&1; then
  echo "code-server no encontrado en PATH, omitiendo instalación de extensiones."
  exit 0
fi

echo "==> Instalando extensiones desde Open VSX..."
for ext in "${EXTENSIONS[@]}"; do
  echo "    $ext"
  code-server --install-extension "$ext" || echo "    -> falló $ext (continuando)"
done

# Continue.dev — no se publica actualizado en Open VSX, se instala desde GitHub Releases
echo "==> Instalando Continue desde GitHub Releases..."
CONTINUE_VSIX_URL=$(
  curl -fsSL https://api.github.com/repos/continuedev/continue/releases/latest \
  | grep browser_download_url \
  | grep '\.vsix' \
  | head -1 \
  | cut -d '"' -f 4
)

if [ -n "$CONTINUE_VSIX_URL" ]; then
  curl -fsSL "$CONTINUE_VSIX_URL" -o /tmp/continue.vsix \
    && code-server --install-extension /tmp/continue.vsix \
    && rm -f /tmp/continue.vsix \
    || echo "    -> falló Continue (continuando)"
else
  echo "    -> no se pudo obtener la URL de descarga de Continue"
fi

echo "==> Listo."