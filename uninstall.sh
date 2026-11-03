#!/usr/bin/env bash
# ccd-org-sync のアンインストール（clone して使った場合）。Homebrew なら:
#   ccd-org-sync agent uninstall && brew uninstall ccd-org-sync
#
#   ./uninstall.sh          自動実行とスクリプトを削除（履歴 ~/.ccd-org-sync は残す）
#   ./uninstall.sh --purge  履歴も削除
set -euo pipefail
BIN="${BIN_DIR:-$HOME/.local/bin}/ccd-org-sync"
if [ -x "$BIN" ]; then
  "$BIN" agent uninstall
else
  launchctl bootout "gui/$(id -u)/com.ccd-org-sync" 2>/dev/null || true
  rm -f "$HOME/Library/LaunchAgents/com.ccd-org-sync.plist"
fi
rm -f "$BIN"
echo "removed script"
if [ "${1:-}" = "--purge" ]; then
  rm -rf "$HOME/.ccd-org-sync"
  echo "removed ~/.ccd-org-sync"
fi
