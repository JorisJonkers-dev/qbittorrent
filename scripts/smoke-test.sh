#!/usr/bin/env bash
# Starts the image restricted (uid 1000, a read-only root, every capability dropped), with only the
# paths the Project mounts writable, waits until it serves, then writes a forwarded port where the
# VPN would and waits until qBittorrent listens on it.
# Usage: scripts/smoke-test.sh <qbittorrent-image>
set -euo pipefail
owned='uid=1000,gid=1000'

cleanup() { docker rm -f smoke-qbittorrent >/dev/null 2>&1 || true; }
trap cleanup EXIT
cleanup

docker run -d --name smoke-qbittorrent --read-only --cap-drop ALL \
  --tmpfs "/tmp:$owned,mode=1777" --tmpfs "/config:$owned" \
  --tmpfs "/media/Completed:$owned" --tmpfs "/media/Seeding:$owned" \
  --tmpfs /run/vpn "$1" >/dev/null

api() { docker exec smoke-qbittorrent curl -fsS -m 5 "http://127.0.0.1:8080$1" 2>/dev/null || true; }

served=false
for _ in $(seq 1 60); do
  [ -n "$(api /api/v2/app/version)" ] && { served=true; break; }
  if [ "$(docker inspect -f '{{.State.Running}}' smoke-qbittorrent)" != true ]; then
    docker logs smoke-qbittorrent 2>&1 | tail -30
    echo "qbittorrent exited before it served" >&2
    exit 1
  fi
  sleep 2
done
[ "$served" = true ] || { docker logs smoke-qbittorrent 2>&1 | tail -30; echo "qbittorrent never served" >&2; exit 1; }
echo "qbittorrent $(api /api/v2/app/version) serves its WebUI"

# The VPN container writes this file as root; the pod mounts it read-only into qBittorrent.
docker exec -u 0 smoke-qbittorrent sh -c 'echo 45678 > /run/vpn/forwarded-port'
port=""
for _ in $(seq 1 20); do
  port=$(api /api/v2/app/preferences | sed -n 's/.*"listen_port":\([0-9]*\).*/\1/p')
  [ "$port" = 45678 ] && break
  sleep 3
done
[ "$port" = 45678 ] || { docker logs smoke-qbittorrent 2>&1 | tail -20; echo "qbittorrent listens on '$port', not the forwarded 45678" >&2; exit 1; }
echo "qbittorrent listens on the forwarded port"

others=$(docker top smoke-qbittorrent -eo pid,uid | tail -n +2 | awk '$2 != 1000')
[ -z "$others" ] || { echo "qbittorrent runs a process as another uid: $others" >&2; exit 1; }
echo "smoke test passed"
