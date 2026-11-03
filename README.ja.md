# ccd-org-sync

[English](README.md) | 日本語

Claude Desktop（macOS）で **org を切り替えるとサイドバーのセッション一覧が別々になる**問題を解消するツール。
org 間で一覧を双方向に同期し、**アーカイブ状態も揃える**。

[jeremy9682/ccd-session-sync](https://github.com/jeremy9682/ccd-session-sync) の考え方を、
「同一アカウント内の複数 org」向けに作り直したもの（元ツールは別アカウント間専用で、同じアカウント内の org 同士は対象外）。

## 背景

Desktop のサイドバー一覧は org ごとに分かれて保存されている。

```
~/Library/Application Support/Claude/claude-code-sessions/<accountUUID>/<orgUUID>/
├── local_<id>.json        # 1 セッション = 1 ファイル（一覧に出るデータ）
└── archived-sessions.idx  # アーカイブ済みセッションの ID 一覧
```

会話本体は org に関係なく `~/.claude/projects/**/*.jsonl` にあるので、一覧のファイルを他の org にコピーすれば両方に表示される。
公式の対応はない（[#48511](https://github.com/anthropics/claude-code/issues/48511) は not planned、[#74662](https://github.com/anthropics/claude-code/issues/74662) はオープン）。

## 同期のルール

| 操作 | もう一方の org で起きること |
|---|---|
| 新しいセッションを作る | 一覧に追加される |
| アーカイブ／アーカイブ解除 | 同じ状態になる（`isArchived` と `archived-sessions.idx` の両方を揃える） |
| 会話が進んで内容が更新される | 更新日時が新しい方に揃う（newer-wins） |
| セッションを削除する | 削除はされない。ただし消した側に復活もしない |

### CLI から `/desktop` で移したセッションの名前

CLI で名前を付けずに `/desktop` で移すと、タイトルが空のまま登録され「General task」と表示される。
タイトルが空のセッションを見つけたら、CLI の会話ファイル（`~/.claude/projects/*/<cliSessionId>.jsonl`）から次の順で名前を付ける。

1. `/rename` で付けた名前
2. AI が付けたタイトル（あれば）
3. 最初の発言の冒頭 40 文字（`[Image #1]` などの印は除く）

Desktop の起動中は、アプリが空のタイトルで書き戻すことがある。その場合も次の同期で付け直され、再起動後に表示される。

- 1 回同期したセッション ID を `~/.ccd-org-sync/synced-ids.json` に記録し、削除されたものを復活させないようにしている
- 3 つ以上の org、複数アカウントの org にも対応（見つかった org すべてを同期する）
- 書き込みは一時ファイル → rename で行い、書きかけのファイルを Desktop が読むことはない
- 変更前後を `~/.ccd-org-sync/git` にコミット。`undo` で直前の同期を戻せる
- 会話本体・認証情報には触らない

## インストール

```bash
git clone https://github.com/HirotoHayasaka/ccd-org-sync
cd ccd-org-sync
./install.sh            # ~/.local/bin に配置 + launchd で自動実行
./install.sh --no-agent # 手動実行だけ
```

自動実行は、org フォルダに変化があったとき（最短 20 秒間隔）と 5 分ごと。変更があったときだけ macOS 通知が出る。
org を追加したら `./install.sh` をもう一度実行すると、新しい org もフォルダ監視の対象に入る。

必要なもの: macOS、`/usr/bin/python3`、`git`

## 使い方

```bash
ccd-org-sync status     # org ごとの件数・アーカイブ数
ccd-org-sync --dry-run  # 書き込まずに変更内容だけ表示
ccd-org-sync            # 同期を実行
ccd-org-sync log        # 同期履歴
ccd-org-sync undo       # 直前の同期を戻す（Desktop を終了してから）
```

もう一方の org で変わった内容は、Desktop の再起動（または org の切り替え）で反映される。

ログ: `~/Library/Logs/ccd-org-sync.log`

## アンインストール

```bash
./uninstall.sh          # エージェントとスクリプトを削除（履歴は残す）
./uninstall.sh --purge  # 履歴 ~/.ccd-org-sync も削除
```

## 注意

- Desktop の**非公開の内部ファイル**を書き換える。アプリの更新で動かなくなる可能性がある
- Desktop の起動中は、アプリがメモリ上の古い状態でファイルを書き戻すことがある。アーカイブが戻ってしまったら `log` / `undo` で確認する
- セッションに含まれる MCP コネクタの設定は org 固有のものもあるが、そのままコピーしている
- `~/.ccd-org-sync/` にはセッションのタイトルや org の ID が入るので、共有しないこと
- Anthropic とは無関係の非公式ツール

## License

MIT
