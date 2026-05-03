# Agent Dashboard — How to Update Your Status

All agents should update the dashboard when they complete tasks, start work, or encounter issues.

## Quick Reference

```bash
UPDATE="/Users/brookehockett/.openclaw/workspace/frame/dashboard/update-status.sh"

# Mark a task complete
$UPDATE <your-agent-id> complete "Description of what you finished"

# Log activity (shows in the feed)
$UPDATE <your-agent-id> activity "What you just did"

# Start working on something
$UPDATE <your-agent-id> start "What you're working on"

# Add an upcoming task
$UPDATE <your-agent-id> upcoming "What's coming next"

# Flag a warning
$UPDATE <your-agent-id> warning "Something needs attention"

# Clear all your warnings
$UPDATE <your-agent-id> clear-warning

# Set your status (active/idle)
$UPDATE <your-agent-id> set-status active
```

## Agent IDs
- molly, frame, nina, rich, paige, riley, buck, sage

## When to Update
- **complete** + **activity**: after finishing any task
- **start**: when beginning a new task
- **set-status active**: at the start of a session
- **set-status idle**: when going quiet
- **warning**: when something needs Brooke's attention

## Dashboard URL
https://brookeruhdhockett-ux.github.io/agent-board/
