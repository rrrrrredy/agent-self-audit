---
name: agent-self-audit
version: 8.0.0
description: "OpenClaw agent system self-audit tool. Triggers: self-audit, system optimization, health check, check agent status, optimize memory. Not for: Skill code security scanning."
tags: [self-audit, memory, skills, cron, optimization]
---

# agent-self-audit 8.0.0

Eight-point agent health self-audit — read and execute.

## 触发条件

User says "self-audit", "system optimization", "health check", "check agent status", "optimize memory", etc. — execute this skill immediately.

## 执行流程

依次检查以下八项，每项先检测现状，再判断是否需要优化，需要操作的事项向用户确认后再执行。

---

### 检查项一：Skills 数量（高优先级）

**检测命令：**
```bash
ls ~/.openclaw/skills/ | wc -l
```

**判断标准：**
- 30-50 个：✅ 健康
- 50-70 个：🟡 偏多，建议检查是否有无用 skill
- 70个以上：🔴 过多，需要清理

**如何识别无用 skill：**
```bash
# 查看各 skill 的安装时间，找出同批次预装的
python3 -c "
import os
from datetime import datetime
skills_dir = os.path.expanduser('~/.openclaw/skills')
from collections import defaultdict
by_time = defaultdict(list)
for name in sorted(os.listdir(skills_dir)):
    path = os.path.join(skills_dir, name)
    if not os.path.isdir(path): continue
    mtime = os.path.getmtime(path)
    dt = datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M')
    by_time[dt].append(name)
for dt, names in sorted(by_time.items()):
    print(f'{dt} ({len(names)}个): {\", \".join(names[:5])}{\" ...\" if len(names)>5 else \"\"}')
"
```

同一批次安装的 skill 若属于以下类别，大概率用不上：
- macOS 专属工具（apple-notes、bear-notes、1password、things-mac 等）
- 智能家居控制（openhue、sonoscli、spotify-player 等）
- 欧美平台（discord、slack、trello、notion、obsidian 等）
- iMessage 相关（bluebubbles、imsg）
- 依赖不存在的 API key（openai-image-gen、gemini 等）
- 与已有 skill 功能完全重叠的（如同时有多个语音转文字 skill）

**操作：** 列出建议删除清单，用户确认后执行。

---

### 检查项二：MEMORY.md 长度（高优先级）

**检测命令：**
```bash
wc -l ~/workspace/MEMORY.md 2>/dev/null || wc -l ~/.openclaw/workspace/MEMORY.md 2>/dev/null
```

**判断标准：**
- < 80 行：✅ 健康
- 80-120 行：🟡 偏长，建议精简
- > 120 行：🔴 过长，需要清理

**精简原则：**
- ✅ 必须保留：我是谁、用户信息、关键服务配置（知识库/API）、定时任务 ID、核心行为规则、高频踩坑
- ❌ 可迁移到 facts.yaml：skills 安装明细、技术细节、历史事件记录、已过期的状态

**操作：** 用户确认后精简，将细节迁移到 `memory/facts.yaml`。

---

### 检查项三：Cron 蒸馏机制（高优先级）

**检测命令：**
```bash
openclaw cron list
```

**检查内容：**
1. 是否有每日记忆整理 cron（00:00 或类似时间）？
2. 是否有周期性蒸馏 cron（每周或每月）？
3. 蒸馏 cron 的 prompt 是否包含：
   - 新事实 → facts.yaml
   - MEMORY.md 精简（硬性行数约束）
   - 旧日志归档或清理

**查看 cron prompt：**
```bash
python3 -c "
import json, os
path = os.path.expanduser('~/.openclaw/cron/jobs.json') if os.path.exists(os.path.expanduser('~/.openclaw/cron/jobs.json')) else '/mnt/openclaw/.openclaw/cron/jobs.json'
with open(path) as f:
    data = json.load(f)
for job in data['jobs']:
    print('---', job['name'])
    print(job['payload']['message'][:300])
    print()
"
```

**操作：** 如果缺少蒸馏步骤，用户确认后更新 cron prompt。

---

### 检查项四：每日日志结构（中优先级）

**检测命令：**
```bash
cat ~/workspace/memory/$(date +%Y-%m-%d).md 2>/dev/null | head -15
```

**判断标准：**
- 文件开头有「必读摘要」（含待跟进/新规则/已完成）：✅ 健康
- 只有完整记录没有摘要分层：🟡 建议添加两层结构

**两层结构规范：**
```
## 【必读摘要】（≤10行，session 开始时快速读取）
⏳ 待跟进：...
📌 新规则：...
✅ 已完成：...

## 【完整记录】（不限行，按任务分块）
...详细内容...
```

**操作：** 用户确认后更新每日 cron 的 prompt，加入两层写法要求。

---

### 检查项五：SOUL.md / 核心配置文件长度（中优先级）

**检测命令：**
```bash
wc -l ~/workspace/SOUL.md ~/workspace/AGENTS.md 2>/dev/null
```

**判断标准：**
- SOUL.md > 150 行：🟡 建议精简（合并小节为段落）
- SOUL.md > 250 行：🔴 必须精简
- AGENTS.md > 500 行：🟡 偏长，检查是否有过时内容

**精简策略（安全操作）：**
- ✅ 安全：把 2-3 行的小节合并成段落
- ✅ 安全：删除重复内容（SOUL.md 和 AGENTS.md 之间）
- ❌ 危险：不删安全规则、身份规则、唯一对话人规则

**操作：** 用户确认后执行，修改后告知用户变更内容。

---

### 检查项六：TOOLS.md 是否填写实际配置（中优先级）

**检测命令：**
```bash
cat ~/workspace/TOOLS.md 2>/dev/null | head -20
```

**判断标准：**
- 只有模板示例内容、没有实际数据：🔴 需要填写
- 有实际的 IP/路径/配置信息：✅ 健康

**建议填写的内容：**
- 沙箱/服务器 IP 或主机名
- 常用 CLI 工具的环境变量
- 关键文件路径（session 日志、cron 配置等）
- 外部服务配置（知识库 ID、API endpoint 等）

**操作：** 引导用户提供信息后填写。

---

### 检查项七：工作区文件整洁度（低优先级）

**检测命令：**
```bash
# 检查残留安装包
ls ~/workspace/*.zip ~/workspace/*.skill 2>/dev/null
# 检查 workspace/skills/ 与 ~/.openclaw/skills/ 的重复目录
python3 -c "
import os
ws = set(os.listdir(os.path.expanduser('~/workspace/skills'))) if os.path.exists(os.path.expanduser('~/workspace/skills')) else set()
installed = set(os.listdir(os.path.expanduser('~/.openclaw/skills')))
overlap = ws & installed
if overlap:
    print('重复目录（可删）：', ', '.join(sorted(overlap)))
else:
    print('无重复目录 ✅')
"
```

**判断标准：**
- 有 .zip/.skill 安装包残留：🟡 建议删除（已安装后无用）
- workspace/skills/ 里有与 ~/.openclaw/skills/ 重复的目录：🟡 建议删除副本

**操作：** 用户确认后清理。

---

### 检查项八：facts.yaml 健康度（中优先级）

**检测命令：**
```bash
# 检查文件存在性
test -f ~/workspace/memory/facts.yaml && echo "✅ 文件存在" || echo "❌ 文件不存在"
# 检查行数
wc -l ~/workspace/memory/facts.yaml 2>/dev/null
# 检查最近修改时间
python3 -c "
import os, datetime
path = os.path.expanduser('~/workspace/memory/facts.yaml')
if os.path.exists(path):
    mtime = os.path.getmtime(path)
    dt = datetime.datetime.fromtimestamp(mtime)
    days_ago = (datetime.datetime.now() - dt).days
    print(f'最近修改：{dt.strftime(\"%Y-%m-%d %H:%M\")}（{days_ago} 天前）')
else:
    print('文件不存在')
"
```

**判断标准：**
- 文件不存在：🔴 需要创建（核心记忆文件缺失）
- 行数 > 500 行：🟡 偏长，建议归档旧事实到 archive/
- 行数 < 10 行：🟡 过少，可能记录不足
- 最近修改 > 30 天：🟡 长期未维护，建议补充近期学到的规则/踩坑
- 文件存在 + 行数合理 + 最近有更新：✅ 健康

> 注意：此路径（`~/workspace/memory/facts.yaml`）为当前 Agent 的标准路径，如你的环境不同请自行替换。

**操作：** 如文件不存在，提示用户是否需要创建初始 facts.yaml 模板。

---

## 输出格式

所有检查完成后，输出标准报告：

```
🦞 Agent 健康自检报告（YYYY-MM-DD）

✅ 健康项：
- [项目名]：[当前状态]

🟡 建议优化：
- [项目名]：[问题描述] → [建议操作]

🔴 需要处理：
- [项目名]：[问题描述] → 是否现在执行？

📊 总体评分：X/8 项健康
```

## 注意事项

- 所有写操作（删除 skill、修改文件、更新 cron）必须先向用户确认，不能自动执行
- 删除 skill 前确认它不在活跃使用中
- 修改 SOUL.md/AGENTS.md 后必须告知用户变更内容
- 不删任何安全规则相关内容

---

### Gotchas

⚠️ `ls ~/.openclaw/skills/ | wc -l` 包含非 skill 目录（如 `.DS_Store`、临时文件）→ 用 `find ~/.openclaw/skills -maxdepth 1 -mindepth 1 -type d | wc -l` 更准确

⚠️ `wc -l MEMORY.md` 含空行也计入，行数偏高时不一定真的内容很多 → 用 `grep -v '^$' MEMORY.md | wc -l` 看实质行数

⚠️ 判断 facts.yaml 是否存在时两个路径都要查（`~/workspace/memory/` 和 `~/.openclaw/workspace/memory/`）→ 分别用 `test -f` 检查，避免路径别名问题

⚠️ 删除 skill 前只看目录名，忽略 skill 是否仍被 cron/heartbeat 引用 → 先 `grep -r "skill名" ~/.openclaw/cron/ ~/.openclaw/workspace/HEARTBEAT.md` 确认无引用

⚠️ 修改 SOUL.md 精简内容时误删安全规则（唯一对话人、SSO 保护等）→ 修改前 diff 对比，安全规则相关段落一律不动

⚠️ Cron 蒸馏任务 prompt 里没有行数硬约束，导致 MEMORY.md 越来越长 → 蒸馏 prompt 必须包含"MEMORY.md 不超过 80 行"的约束

---

### Hard Stop

**同一工具调用失败超过 3 次，立即停止，不再尝试。** 列出所有失败方案及原因，标记 **"需要人工介入"**，等待人工确认。

---

## Heartbeat 自动触发（V6 新增）

除用户主动触发外，支持通过 heartbeat 机制定期自动执行轻量健康检查。

### 配置方式

在用户的 `HEARTBEAT.md` 中追加以下规则（每周一执行全量自检）：

```
- agent-self-audit 周检：当前为周一且本周尚未执行自检时，自动运行全量健康检查，输出报告
```

或配置 cron（精确时间触发）：
```bash
# 每周一 09:00（UTC 01:00）自动自检
openclaw cron add --name "agent-weekly-audit" --cron "0 1 * * 1" --message "执行 agent-self-audit 健康检查，检查 Skills 数量、MEMORY.md 长度、facts.yaml 健康度等八项指标，输出简要报告"
```

### Heartbeat 轻量模式

heartbeat 触发时，执行精简版检查（只检查最关键的 3 项，不做修复）：
1. MEMORY.md 行数（是否超过 80 行）
2. Skills 数量（是否超过 70 个）
3. facts.yaml 是否存在

输出格式：
```
🦞 快速健康扫描：
- MEMORY.md: {N}行 {✅/🟡/🔴}
- Skills数量: {N}个 {✅/🟡/🔴}
- facts.yaml: {存在/缺失} {✅/🔴}
如有问题，回复"自检"执行完整检查
```

---

## Changelog

### 8.0.0（2026-04-08）
- 修正 cron add 命令格式：`--schedule`→`--cron`，`--prompt`→`--message`（符合 openclaw cron add 实际参数）
- 新建 `scripts/health_check.sh`（3 项关键检查快速脚本）
- 新建 `references/audit-criteria.md`（各检查项判断标准详细说明）
- frontmatter version V7 → V8，H1 标题同步为 V8

### v7（当前已安装版）
- 新增 Heartbeat 轻量模式（3 项快速检查，不做修复）
- Heartbeat 配置方式：HEARTBEAT.md 规则 + cron 精确时间 两种方式
- 补充 Gotchas（5 条：wc -l 含空行、facts 两路径、删 skill 前检查引用等）
- 已有 Hard Stop 独立三级标题

### v6（历史版本）
- 新增 Heartbeat 自动触发支持
- 新增检查项七：工作区文件整洁度

### v1-v5（历史版本）
- 初版八项健康自检（Skills 数量、MEMORY.md 长度、Cron、每日日志、SOUL.md、TOOLS.md、整洁度、facts.yaml）
