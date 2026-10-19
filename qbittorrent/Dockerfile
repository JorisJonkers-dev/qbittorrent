FROM linuxserver/qbittorrent:5.2.3_v2.0.14-ls474@sha256:a00b6a597a3832a1814cde0ef60abc55c94644f3f80902c3432f6af6de8d4a96

# No setuid or setgid binary: the estate's pods do not yet forbid privilege escalation.
RUN find / -xdev -perm /6000 -type f -exec chmod ug-s {} +

COPY qbittorrent-start /usr/local/bin/qbittorrent-start

# deploy, which owns the media library and this config already; the image runs read-only as it.
USER 1000:1000
ENTRYPOINT ["/usr/local/bin/qbittorrent-start"]
CMD []
