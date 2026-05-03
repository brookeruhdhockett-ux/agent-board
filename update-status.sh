#!/bin/bash
# Usage: update-status.sh <agent_id> <action> <data>
# Actions: complete, start, upcoming, warning, clear-warning, set-status
#
# Examples:
#   update-status.sh frame complete "Fixed Reel Lab memory crash"
#   update-status.sh frame start "Wiring dashboard to live data"
#   update-status.sh frame upcoming "VA check-in — evening"
#   update-status.sh frame warning "Reel Lab may crash again"
#   update-status.sh frame clear-warning
#   update-status.sh frame set-status active
#   update-status.sh frame activity "Built agent dashboard"

AGENT="$1"
ACTION="$2"
DATA="$3"
STATUS_FILE="/Users/brookehockett/.openclaw/workspace/agent-status.json"
DASHBOARD_DIR="/Users/brookehockett/.openclaw/workspace/frame/dashboard"

if [ -z "$AGENT" ] || [ -z "$ACTION" ]; then
  echo "Usage: update-status.sh <agent_id> <action> [data]"
  exit 1
fi

python3 << PYEOF
import json, datetime, sys, os

status_file = "$STATUS_FILE"
agent = "$AGENT"
action = "$ACTION"
data = """$DATA"""

with open(status_file) as f:
    s = json.load(f)

now = datetime.datetime.now().astimezone().isoformat()
s['updated_at'] = now

if agent not in s['agents']:
    print(f"Unknown agent: {agent}")
    sys.exit(1)

a = s['agents'][agent]
a['last_active'] = now

if action == 'complete':
    # Move from in_progress if there, add to completed
    if data in a['today'].get('in_progress', []):
        a['today']['in_progress'].remove(data)
    if data not in a['today']['completed']:
        a['today']['completed'].append(data)
    a['stats']['tasks_today'] = len(a['today']['completed'])
    a['stats']['tasks_week'] = a['stats'].get('tasks_week', 0) + 1

elif action == 'start':
    if data not in a['today'].get('in_progress', []):
        a['today'].setdefault('in_progress', []).append(data)
    # Remove from upcoming if there
    if data in a['today'].get('upcoming', []):
        a['today']['upcoming'].remove(data)

elif action == 'upcoming':
    if data not in a['today'].get('upcoming', []):
        a['today'].setdefault('upcoming', []).append(data)

elif action == 'warning':
    if data not in a.get('warnings', []):
        a.setdefault('warnings', []).append(data)

elif action == 'clear-warning':
    a['warnings'] = []

elif action == 'set-status':
    a['status'] = data

elif action == 'activity':
    s.setdefault('activity', []).insert(0, {
        'agent': agent,
        'text': data,
        'time': now
    })
    # Keep last 30 entries
    s['activity'] = s['activity'][:30]

else:
    print(f"Unknown action: {action}")
    sys.exit(1)

with open(status_file, 'w') as f:
    json.dump(s, f, indent=2)

print(f"OK: {agent} -> {action}: {data}")
PYEOF

# Copy to dashboard repo and push
cp "$STATUS_FILE" "$DASHBOARD_DIR/status.json"
cd "$DASHBOARD_DIR" && git add status.json && git commit -m "status update: $AGENT $ACTION" --quiet 2>/dev/null && git push origin main --quiet 2>/dev/null
echo "Dashboard updated."
