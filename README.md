# ccd-org-sync

English | [日本語](README.ja.md)

Keep the **Claude Desktop** (macOS) Claude Code sidebar identical across **organizations and accounts** — including archive state.

Inspired by [jeremy9682/ccd-session-sync](https://github.com/jeremy9682/ccd-session-sync), which syncs between *different accounts*. This tool also handles **multiple orgs inside the same account** (which `ccd-session-sync` refuses), and any number of accounts/orgs at once.

> Unofficial. Not affiliated with or endorsed by Anthropic. It edits Claude Desktop's internal, undocumented files — an app update may break it. Use at your own risk.

## The problem

Claude Desktop stores the sidebar session list per org:

```
~/Library/Application Support/Claude/claude-code-sessions/<accountUUID>/<orgUUID>/
├── local_<id>.json        # one sidebar entry per session
└── archived-sessions.idx  # IDs of archived sessions
```

Switch org or account and the sidebar looks empty — but the conversations themselves live in `~/.claude/projects/**/*.jsonl`, shared by every org. Copying the small index files is enough to show the same list everywhere.

There is no official setting for this ([#48511](https://github.com/anthropics/claude-code/issues/48511) closed as not planned, [#74662](https://github.com/anthropics/claude-code/issues/74662) open).

## What it syncs

| You do this in one org | Other orgs get |
|---|---|
| Create a session | The session appears |
| Archive / unarchive | Same archive state (`isArchived` and `archived-sessions.idx`) |
| Keep chatting (entry updated) | Newest version wins (by file mtime) |
| Delete a session | Not deleted elsewhere — but never resurrected in the org you deleted it from |

Plus: sessions moved from the CLI with `/desktop` without a name show up as "General task". ccd-org-sync fills in the empty title from the CLI transcript: `/rename` name → AI title → first prompt (40 chars).

Safety:

- Atomic writes (temp file + rename) — Desktop never reads a half-written file
- Every change is snapshotted to a local git repo (`~/.ccd-org-sync/git`); `undo` reverts the last sync
- Never touches transcripts or credentials
- Newly appearing orgs start empty and receive everything; deletion tracking is per org

## Install

Requirements: macOS, `/usr/bin/python3` (Xcode Command Line Tools), `git`. Standard library only.

```bash
git clone https://github.com/HirotoHayasaka/ccd-org-sync
cd ccd-org-sync
./install.sh            # installs to ~/.local/bin and registers a launchd agent
./install.sh --no-agent # script only, run manually
```

The agent runs when the session folders change (at most every 20 s) and every 5 minutes, and posts a macOS notification only when something changed. Re-run `./install.sh` after adding an org/account to watch it immediately (the 5‑minute run picks it up anyway).

## Usage

```bash
ccd-org-sync status     # entries / archived per org
ccd-org-sync --dry-run  # show what would change, write nothing
ccd-org-sync            # sync now
ccd-org-sync log        # sync history
ccd-org-sync undo       # revert the last sync (quit Desktop first)
```

Changes from other orgs appear after restarting Claude Desktop (it reads the list at startup). Log: `~/Library/Logs/ccd-org-sync.log`. CLI messages are in Japanese.

## Uninstall

```bash
./uninstall.sh          # remove agent and script, keep history
./uninstall.sh --purge  # also delete ~/.ccd-org-sync
```

## Known limitations

- While Desktop is running it may write back its in-memory state (e.g. undo an archive or blank a title). The next sync / restart usually settles it; check `log` and `undo` if not.
- Org-specific MCP connector settings inside an entry are copied as-is.
- `~/.ccd-org-sync/` contains session titles and account/org IDs. Don't share it.
- macOS only (launchd, osascript).

## License

MIT
