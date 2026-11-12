# Agents

Guidance for any coding agent working in this repository.

- Agent contract: [CLAUDE.md](CLAUDE.md), which points at [the estate contract](https://github.com/JorisJonkers-dev/workspace/blob/main/CLAUDE.md).
- What this repository holds: the qBittorrent image (`qbittorrent/Dockerfile`, `qbittorrent/qbittorrent-start`) and its Project declaration (`deploy/qbittorrent.project.yml`). See [README.md](README.md).

## Build and test

```bash
shellcheck scripts/*.sh qbittorrent/qbittorrent-start
docker build -t qbittorrent:ci qbittorrent
scripts/smoke-test.sh qbittorrent:ci
```

CI (`.github/workflows/ci.yml`) runs the same lint, image build and restricted smoke test; the `Pipeline Complete` check gates merges.
