#!/bin/bash
# Fetch 7-day forecast for Kendall, Miami FL from Open-Meteo (no API key needed)
CACHE="/tmp/eww-weather.json"
CACHE_AGE=1800  # 30 minutes

# Use cache if fresh
if [[ -f "$CACHE" ]] && (( $(date +%s) - $(stat -c %Y "$CACHE") < CACHE_AGE )); then
    cat "$CACHE"
    exit 0
fi

URL="https://api.open-meteo.com/v1/forecast"
URL+="?latitude=25.68&longitude=-80.36"
URL+="&daily=temperature_2m_max,temperature_2m_min,weathercode"
URL+="&timezone=America%2FNew_York&forecast_days=7&temperature_unit=fahrenheit"

DATA=$(curl -sf --max-time 10 "$URL")

if [[ -z "$DATA" ]]; then
    # Return cached data if fetch failed, otherwise empty
    [[ -f "$CACHE" ]] && cat "$CACHE" || echo "[]"
    exit 0
fi

echo "$DATA" | python3 -c "
import json, sys
from datetime import datetime

icons = {
    0:  '󰖙',
    1:  '󰖐', 2:  '󰖐', 3:  '󰖐',
    45: '󰖑', 48: '󰖑',
    51: '󰖗', 53: '󰖗', 55: '󰖗',
    61: '󰖗', 63: '󰖗', 65: '󰖗',
    71: '󰖘', 73: '󰖘', 75: '󰖘', 77: '󰖘',
    80: '󰖖', 81: '󰖖', 82: '󰖖',
    85: '󰖘', 86: '󰖘',
    95: '󰖓', 96: '󰖓', 99: '󰖓',
}

data = json.load(sys.stdin)
d    = data['daily']
out  = []

for i in range(7):
    dt   = datetime.strptime(d['time'][i], '%Y-%m-%d')
    code = d['weathercode'][i]
    out.append({
        'day':  dt.strftime('%a'),
        'date': dt.strftime('%m/%d'),
        'high': round(d['temperature_2m_max'][i]),
        'low':  round(d['temperature_2m_min'][i]),
        'icon': icons.get(code, '󰖐'),
    })

print(json.dumps(out))
" | tee "$CACHE"
