# LIGGGHTS Syntax Skill for Claude Code

Claude Code skill providing comprehensive LIGGGHTS-PUBLIC v3.X input script syntax reference. Helps AI agents and users write, debug, and review LIGGGHTS DEM simulation scripts.

## What This Skill Covers

- **Parsing rules** — `$var`, `${var}`, `$(formula)`, `&` continuation, `#` comments, quoting
- **Input script structure** — 4-part format (Initialization → Atoms → Settings → Run)
- **Complete command reference** — all 100+ LIGGGHTS commands organized by category
- **Contact model syntax** — the 3.X `model` keyword system replacing old 2.X slash syntax
- **Variable system** — all 12 styles, formula elements, `$var` vs `v_var` evaluation
- **Unit systems** — all 8 styles (si, cgs, lj, real, metal, micro, nano, electron)
- **Working examples** — minimal simulation, multi-material, mesh walls, loops

Based on LIGGGHTS-PUBLIC v3.8.0 official documentation.

## Quick Install

### For Users (Claude Code)

**Option A: Git Clone (recommended)**
```bash
mkdir -p ~/.claude/skills/skills
git clone https://github.com/qxyanda/liggghts-syntax-skill.git ~/.claude/skills/skills/liggghts-syntax-tmp
cp -r ~/.claude/skills/skills/liggghts-syntax-tmp/* ~/.claude/skills/
rm -rf ~/.claude/skills/skills/liggghts-syntax-tmp
```

**Option B: One-liner (Linux/macOS/WSL)**
```bash
curl -fsSL https://raw.githubusercontent.com/HT-YD/liggghts-syntax-skill/main/install.sh | bash
```

**Option C: PowerShell (Windows)**
```powershell
iwr -Uri https://raw.githubusercontent.com/HT-YD/liggghts-syntax-skill/main/install.ps1 | iex
```

**Option D: Manual**
```bash
git clone https://github.com/qxyanda/liggghts-syntax-skill.git
cp -r liggghts-syntax-skill/skills ~/.claude/skills/
cp -r liggghts-syntax-skill/.claude-plugin ~/.claude/skills/
```

### For AI Agents (Automated Install)

Agents can self-install this skill by running:

```bash
SKILL_DIR="$HOME/.claude/skills"
mkdir -p "$SKILL_DIR/skills/liggghts-syntax"
curl -fsSL https://raw.githubusercontent.com/HT-YD/liggghts-syntax-skill/main/skills/liggghts-syntax/SKILL.md \
  -o "$SKILL_DIR/skills/liggghts-syntax/SKILL.md"
```

Or via the bundled install script:

```bash
curl -fsSL https://raw.githubusercontent.com/HT-YD/liggghts-syntax-skill/main/install.sh | bash
```

## Usage

Once installed, invoke the skill by mentioning any of these trigger phrases:

- "LIGGGHTS syntax"
- "LIGGGHTS script"
- "liggghts command"
- "granular script"
- "DEM script syntax"
- "how to write LIGGGHTS input"

Or use `/liggghts-syntax` slash command.

The skill activates automatically when Claude Code detects these phrases, providing instant access to the full syntax reference.

## Repository Structure

```
liggghts-syntax-skill/
  skills/
    liggghts-syntax/
      SKILL.md              # Main skill file (~600 lines)
  .claude-plugin/
    plugin.json             # Plugin metadata
    marketplace.json         # Marketplace registration
  install.sh                # Bash/Zsh installer
  install.ps1               # PowerShell installer
  example/
    in.simple               # Minimal working input script
  README.md
  LICENSE
```

## Example Output

When invoked, the skill provides:
- Exact syntax for any LIGGGHTS command
- Contact model selection examples (hertz, hooke, sjkr, cdt, etc.)
- Material property requirements for each model
- Working copy-paste script templates
- Common mistakes and restrictions

## Requirements

- Claude Code (any version with skill support)
- No external dependencies
- No LIGGGHTS installation required (this is a reference skill)

## Contributing

This skill is derived from the official LIGGGHTS-PUBLIC documentation.
To suggest improvements:

1. Fork the repository
2. Edit `skills/liggghts-syntax/SKILL.md`
3. Submit a PR

## License

MIT — see [LICENSE](LICENSE) file.

## Related Projects

- [LIGGGHTS-PUBLIC](https://github.com/CFDEMproject/LIGGGHTS-PUBLIC) — Open-source DEM simulation software
- [CFDEM(R)project](https://www.cfdem.com) — Official project website
