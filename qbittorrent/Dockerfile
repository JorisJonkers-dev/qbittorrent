FROM linuxserver/qbittorrent:5.2.3_v2.0.14-ls477@sha256:457e4eec2ee3f5e4ef59f237ad51f6143deba9f7445ab48bb5204a98888ef9aa

# No setuid or setgid binary: the estate's pods do not yet forbid privilege escalation.
RUN find / -xdev -perm /6000 -type f -exec chmod ug-s {} +

COPY qbittorrent-start /usr/local/bin/qbittorrent-start

# deploy, which owns the media library and this config already; the image runs read-only as it.
USER 1000:1000
ENTRYPOINT ["/usr/local/bin/qbittorrent-start"]
CMD []
