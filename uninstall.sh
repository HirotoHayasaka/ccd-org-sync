#!/usr/bin/env bash
# ccd-org-sync のアンインストール。
#   ./uninstall.sh          エージェントとスクリプトを削除（履歴 ~/.ccd-org-sync は残す）
#   ./uninstall.sh --purge  履歴も削除
set -euo pipefail
LABEL="com.ccd-org-sync"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/$LABEL.plist" "${BIN_DIR:-$HOME/.local/bin}/ccd-org-sync"
echo "removed agent and script"
if [ "${1:-}" = "--purge" ]; then
  rm -rf "$HOME/.ccd-org-sync"
  echo "removed ~/.ccd-org-sync"
fi
