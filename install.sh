#!/usr/bin/env bash
# ccd-org-sync のインストール（clone して使う場合）。Homebrew なら:
#   brew install hirotohayasaka/tap/ccd-org-sync && ccd-org-sync agent install
#
#   ./install.sh               ~/.local/bin に配置 + 自動実行を登録
#   ./install.sh --no-agent    スクリプトだけ（手動実行のみ）
set -euo pipefail
cd "$(dirname "$0")"

[ "$(uname)" = "Darwin" ] || { echo "ERROR: macOS 専用です / macOS only"; exit 1; }
[ -x /usr/bin/python3 ] || { echo "ERROR: /usr/bin/python3 がありません。xcode-select --install を実行してください"; exit 1; }
command -v git >/dev/null || { echo "ERROR: git がありません / git is required"; exit 1; }

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$BIN_DIR"
install -m 755 bin/ccd-org-sync "$BIN_DIR/ccd-org-sync"
echo "installed: $BIN_DIR/ccd-org-sync"
case ":$PATH:" in *":$BIN_DIR:"*) ;; *) echo "NOTE: $BIN_DIR を PATH に追加してください" ;; esac

[ "${1:-}" = "--no-agent" ] && exit 0
PATH="$BIN_DIR:$PATH" "$BIN_DIR/ccd-org-sync" agent install
