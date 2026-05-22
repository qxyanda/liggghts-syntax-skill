# LIGGGHTS Syntax Skill for Claude Code

Claude Code skill providing comprehensive LIGGGHTS-PUBLIC v3.X input script syntax reference.
Helps AI agents and users write, debug, and review LIGGGHTS DEM simulation scripts.

## What This Skill Covers

- **Parsing rules** — `$var`, `${var}`, `$(formula)`, `&` continuation, `#` comments, quoting
- **Input script structure** — 4-part format (Initialization → Atoms → Settings → Run)
- **Complete command reference** — all 100+ LIGGGHTS commands organized by category
- **Contact model syntax** — the 3.X `model` keyword system replacing old 2.X slash syntax
- **Variable system** — all 12 styles, formula elements, `$var` vs `v_var` evaluation
- **Unit systems** — all 8 unit styles with dimensions table
- **Working examples** — minimal simulation, multi-material, mesh walls, loops

Based on LIGGGHTS-PUBLIC v3.8.0 official documentation.

## Quick Install

### Linux / macOS / WSL

```bash
curl -fsSL https://raw.githubusercontent.com/qxyanda/liggghts-syntax-skill/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -Uri https://raw.githubusercontent.com/qxyanda/liggghts-syntax-skill/main/install.ps1 | iex
```

### Manual Install

```bash
git clone https://github.com/qxyanda/liggghts-syntax-skill.git
mkdir -p ~/.claude/skills/liggghts-syntax
cp liggghts-syntax-skill/skills/liggghts-syntax/SKILL.md ~/.claude/skills/liggghts-syntax/
```

### AI Agent Self-Install

```bash
mkdir -p ~/.claude/skills/liggghts-syntax
curl -fsSL https://raw.githubusercontent.com/qxyanda/liggghts-syntax-skill/main/skills/liggghts-syntax/SKILL.md \
  -o ~/.claude/skills/liggghts-syntax/SKILL.md
```

## Usage

Invoke the skill by mentioning any trigger phrase:

- "LIGGGHTS syntax"
- "LIGGGHTS script"
- "liggghts command"
- "granular script"
- "DEM script syntax"
- "how to write LIGGGHTS input"

Or use `/liggghts-syntax` slash command.

## Install Location

```
~/.claude/skills/
  liggghts-syntax/
    SKILL.md               # Main skill file
    example/
      in.simple            # Working example script
  philosophy/              # (existing, unaffected)
    SKILL.md
```

`liggghts-syntax` installs as a standalone skill, independent from any other plugins.

## Repository Structure

```
liggghts-syntax-skill/
  skills/
    liggghts-syntax/
      SKILL.md              # Main skill content
  example/
    in.simple               # Minimal working input script
  install.sh                # Bash/Zsh installer
  install.ps1               # PowerShell installer
  README.md
  LICENSE
```

## Requirements

- Claude Code with skill support
- No external dependencies
- No LIGGGHTS installation required (reference skill only)

## License

MIT — see [LICENSE](LICENSE) file.
