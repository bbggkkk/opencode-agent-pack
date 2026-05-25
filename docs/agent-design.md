# Agent Design

This pack provides five opencode agents:

| Agent | Role | Type |
| --- | --- | --- |
| `novelist` | fiction writer | creative |
| `novel-editor` | fiction editor | review |
| `lyricist` | lyric writer | creative |
| `lyric-editor` | lyric editor | review |
| `scientist` | research & LaTeX paper writing | research |

The design separates creation from feedback. Writer agents produce drafts. Editor agents diagnose problems, explain trade-offs, and suggest revisions. This separation helps users run a draft-review-rewrite loop without mixing creative generation and critique in one role. The scientist agent extends the pack beyond creative writing into academic research writing.

## Korean-First Behavior

Korean is the default language. The agents prioritize natural Korean prose, believable dialogue, emotional continuity, Korean lyric pronunciation, and genre-specific expectations.

English is available when requested, but English support should not weaken the Korean-first defaults. The scientist agent supports bilingual output for LaTeX papers.

## Safety And Originality

The agents should avoid direct imitation of living authors, specific copyrighted songs, and protected lyrics. They can work from broad creative traits such as atmosphere, structure, emotion, tempo, or genre.

## Distribution Model

Users install agents via the interactive `install.sh` script:

```bash
git clone https://github.com/bbggkkk/opencode-agent-pack.git
cd opencode-agent-pack
./install.sh
```

The script accepts an optional argument for non-interactive use:

```bash
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 1
curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-agent-pack/master/install.sh | sh -s -- 2
```

- `1` → project-local install (`.opencode/agents/`)
- `2` → global install (`~/.config/opencode/agents/`)

Manual copy is also supported:
```bash
cp agents/*.md ~/.config/opencode/agents/
```

After installation, restart opencode for changes to take effect.
