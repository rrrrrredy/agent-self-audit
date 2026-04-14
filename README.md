# agent-self-audit

OpenClaw agent system self-audit tool — eight-point health check for your AI agent.

An [OpenClaw](https://github.com/openclaw/openclaw) Skill for monitoring and optimizing your agent's health: memory size, skill count, cron jobs, daily logs, config files, workspace cleanliness, and more.

## Installation

### Option A: OpenClaw (recommended)
```bash
# Clone to OpenClaw skills directory
git clone https://github.com/rrrrrredy/agent-self-audit ~/.openclaw/skills/agent-self-audit

# Run setup
bash ~/.openclaw/skills/agent-self-audit/scripts/health_check.sh
```

### Option B: Standalone
```bash
git clone https://github.com/rrrrrredy/agent-self-audit
cd agent-self-audit
bash scripts/health_check.sh
```

## Dependencies

### Python packages
None (uses only built-in Python and bash)

### Other Skills (optional)
None

## Usage

Tell your agent:
- "Run a self-audit" / "Health check"
- "Check agent status" / "Optimize memory"
- "System optimization"

The skill checks 8 areas:
1. **Skills count** — too many installed skills bloat context
2. **MEMORY.md length** — long-term memory file shouldn't exceed ~80 lines
3. **Cron distillation** — ensure periodic memory maintenance is configured
4. **Daily log structure** — two-tier format (summary + full record)
5. **Core config file length** — SOUL.md / AGENTS.md shouldn't be too long
6. **TOOLS.md completeness** — should contain actual config, not just templates
7. **Workspace cleanliness** — leftover install packages, duplicate directories
8. **facts.yaml health** — existence, size, recency of the atomic facts store

## Project Structure

```
agent-self-audit/
├── SKILL.md              # Main skill definition
├── scripts/
│   └── health_check.sh   # Quick 3-point health scan script
├── references/
│   └── audit-criteria.md # Detailed criteria for each check
└── README.md
```

## License

MIT
