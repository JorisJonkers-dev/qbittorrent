# qbittorrent

[qBittorrent](https://www.qbittorrent.org) as the estate runs it: the
[linuxserver.io](https://www.linuxserver.io) image, run as `deploy` (1000:1000)
under a read-only root filesystem, behind the platform's VPN. deploy-kit
delivers it as the Project `qbittorrent`.

## What the image changes

`qbittorrent/Dockerfile` names `USER 1000:1000`, clears every setuid and setgid
bit, and starts `qbittorrent-nox` directly rather than through s6, which wants a
`/run` the pod does not give it. Before it starts, `qbittorrent-start`:
- holds the settings the estate manages in `qBittorrent.conf`: the WebUI trusts
  loopback and leaves CSRF to the SSO in front of it; the session seeds from
  `/media/Seeding` and completes into `/media/Completed`, with no DHT, PeX or
  LSD, and no program on completion;
- points `TMPDIR` at `/tmp`, since the image's own sits below `/run`;
- watches `/run/vpn/forwarded-port`, which the VPN rewrites whenever the provider
  moves the forwarded port, and sets that as qBittorrent's listen port through
  its WebUI, with no restart.

## Running it

`deploy/qbittorrent.project.yml` and `deploy/env/` declare the Project:
- **VPN:** every connection leaves through the platform's VPN, and peers dial
  the port it forwards (`vpn: {forwardedPort: true}`).
- **media:** torrents seed from the Platform document's `seeding` library at
  `/media/Seeding` and complete into the `media` library's `Completed` folder,
  at the paths the existing torrents name.
- **config:** a claim the platform's `file-backup` copies nightly, holding every
  torrent's resume data.

## Versions

This repository's version is qBittorrent's: release `v5.2.3` runs qBittorrent
5.2.3. Renovate opens a pull request for each update. A minor or patch update
merges itself once `Pipeline Complete` passes; a major release waits for
approval on the Dependency Dashboard. A linuxserver rebuild of the same
qBittorrent ships with the next release. When the `FROM` tag in
`qbittorrent/Dockerfile` names a new version on `main`, `release.yml` releases
it and publishes the image and the Intent Fragment.

`scripts/smoke-test.sh` starts the image restricted, waits until it serves, and
checks it takes a forwarded port; CI runs it on every change.

## Licence

This repository's own files are MIT: see [LICENSE](LICENSE). qBittorrent is
GPL-2.0, as is the linuxserver.io image built from it.
