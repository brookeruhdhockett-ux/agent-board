#!/bin/bash
# Run daily at midnight to reset today's task lists for all agents
# Keeps activity feed and warnings intact

STATUS_FILE="/Users/brookehockett/.openclaw/workspace/agent-status.json"
DASHBOARD_DIR="/Users/brookehockett/.openclaw/workspace/frame/dashboard"

python3 << 'PYEOF'
import json, datetime

status_file = "/Users/brookehockett/.openclaw/workspace/agent-status.json"

with open(status_file) as f:
    s = json.load(f)

now = datetime.datetime.now().astimezone().isoformat()
s['updated_at'] = now

for key, agent in s['agents'].items():
    agent['today'] = {
        'completed': [],
        'in_progress': [],
        'upcoming': []
    }
    agent['stats']['tasks_today'] = 0
    agent['status'] = 'idle'

with open(status_file, 'w') as f:
    json.dump(s, f, indent=2)

print("Daily reset complete.")
PYEOF

cp "$STATUS_FILE" "$DASHBOARD_DIR/status.json"
cd "$DASHBOARD_DIR" && git add status.json && git commit -m "daily reset: $(date +%Y-%m-%d)" --quiet 2>/dev/null && git push origin main --quiet 2>/dev/null
echo "Dashboard reset and pushed."
