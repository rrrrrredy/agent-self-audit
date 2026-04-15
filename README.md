# agent-self-audit

OpenClaw agent health check and self-audit tool — 8-point system diagnostic.

> OpenClaw Skill — works with [OpenClaw](https://github.com/openclaw/openclaw) AI agents

## What It Does

Performs an 8-point health audit of your OpenClaw agent: checks installed skill count, MEMORY.md length, cron distillation setup, daily log structure, core config file sizes, TOOLS.md configuration, workspace cleanliness, and facts.yaml health. Outputs a structured health report with actionable recommendations. Supports both full interactive audits and lightweight heartbeat-triggered quick scans.

## Quick Start

```bash
# Install via ClawHub (recommended)
openclaw skill install agent-self-audit

# Or clone this repo into your skills directory
git clone https://github.com/rrrrrredy/agent-self-audit.git ~/.openclaw/skills/agent-self-audit
```

## Features

- **8-point health diagnostic**: Skills count, MEMORY.md length, cron distillation, daily log structure, SOUL.md/AGENTS.md size, TOOLS.md config, workspace cleanliness, facts.yaml health
- **Traffic-light scoring**: ✅ Healthy / 🟡 Needs attention / 🔴 Requires action for each check
- **Smart skill cleanup**: Identifies unused pre-installed skills (macOS-only, smart home, EU platforms, duplicate functionality)
- **Memory optimization**: Detects oversized MEMORY.md and suggests migration of details to facts.yaml
- **Cron distillation audit**: Verifies daily/weekly memory distillation jobs exist with proper constraints
- **Heartbeat lightweight mode**: 3-item quick scan (MEMORY.md lines, skill count, facts.yaml existence) for periodic automated checks
- **Safe-by-default**: All write operations require explicit user confirmation before execution

## Usage

```
"自检"              → Full 8-point health audit
"系统优化"           → Full audit with optimization suggestions
"健康检查"           → Full audit
"检查龙虾状态"       → Full audit
"优化记忆"           → Memory-focused audit
```

### Heartbeat Quick Scan

Add to `HEARTBEAT.md` for weekly automated checks:

```
- agent-self-audit 周检：当前为周一且本周尚未执行自检时，自动运行全量健康检查，输出报告
```

Or via cron:

```bash
openclaw cron add --name "agent-weekly-audit" --cron "0 1 * * 1" \
  --message "执行 agent-self-audit 健康检查"
```

## Project Structure

```
agent-self-audit/
├── SKILL.md              # Main skill definition
├── scripts/
│   └── health_check.sh   # Quick 3-item health check script
├── references/
│   └── audit-criteria.md # Detailed check criteria
└── .gitignore
```

## Requirements

- [OpenClaw](https://github.com/openclaw/openclaw) agent runtime
- Python 3 (for inline diagnostic scripts)
- Standard Unix tools (`wc`, `ls`, `find`, `grep`)

## License

[MIT](LICENSE)
