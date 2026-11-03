#!/usr/bin/env bash
# ccd-org-sync のインストール。スクリプトを ~/.local/bin に置き、launchd エージェントを登録する。
#   ./install.sh               インストール + 自動実行
#   ./install.sh --no-agent    スクリプトだけ（手動実行のみ）
set -euo pipefail
cd "$(dirname "$0")"

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
LABEL="com.ccd-org-sync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
CCS="$HOME/Library/Application Support/Claude/claude-code-sessions"
LOG="$HOME/Library/Logs/ccd-org-sync.log"

mkdir -p "$BIN_DIR"
install -m 755 bin/ccd-org-sync "$BIN_DIR/ccd-org-sync"
echo "installed: $BIN_DIR/ccd-org-sync"
case ":$PATH:" in *":$BIN_DIR:"*) ;; *) echo "NOTE: $BIN_DIR を PATH に追加してください" ;; esac

[ "${1:-}" = "--no-agent" ] && exit 0
[ -d "$CCS" ] || { echo "ERROR: $CCS がありません（Claude Desktop を一度起動してください）"; exit 1; }

# 監視対象: claude-code-sessions 自体（新しいアカウント）・アカウント（新しい org）・org フォルダ
watch=""
while IFS= read -r d; do
  watch+="    <string>$d</string>"$'\n'
done < <(find "$CCS" -mindepth 0 -maxdepth 2 -type d | sort)

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
mkdir -p "$(dirname "$PLIST")"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$BIN_DIR/ccd-org-sync</string>
    <string>--notify</string>
  </array>
  <key>WatchPaths</key>
  <array>
$watch  </array>
  <key>StartInterval</key>
  <integer>300</integer>
  <key>ThrottleInterval</key>
  <integer>20</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$LOG</string>
  <key>StandardErrorPath</key>
  <string>$LOG</string>
</dict>
</plist>
EOF
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "loaded: $PLIST"
echo "org を追加したら ./install.sh を再実行すると監視対象に入ります"
