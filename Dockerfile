# SPIRE intermediate-CA rotator: step + step-kms-plugin (KMS signing) + kubectl.
# Debian base (glibc) — smallstep binaries are glibc-linked, won't run on musl/alpine.
FROM debian:12-slim
ARG STEP_VERSION=0.30.6
ARG KMS_PLUGIN_VERSION=0.17.0
ARG KUBECTL_VERSION=1.31.1
RUN set -eux; \
    apt-get update; apt-get install -y --no-install-recommends ca-certificates curl libpcsclite1; \
    curl -sSL "https://github.com/smallstep/cli/releases/download/v${STEP_VERSION}/step_linux_amd64.tar.gz" | tar xz -C /tmp; \
    install -m0755 /tmp/step_linux_amd64/bin/step /usr/local/bin/step; \
    curl -sSL "https://github.com/smallstep/step-kms-plugin/releases/download/v${KMS_PLUGIN_VERSION}/step-kms-plugin_${KMS_PLUGIN_VERSION}_linux_amd64.tar.gz" | tar xz -C /tmp; \
    install -m0755 "$(find /tmp -name step-kms-plugin -type f | head -1)" /usr/local/bin/step-kms-plugin; \
    curl -sSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl; \
    chmod 0755 /usr/local/bin/kubectl; \
    apt-get purge -y curl; apt-get autoremove -y; rm -rf /var/lib/apt/lists/* /tmp/*
COPY rotate.sh /usr/local/bin/rotate.sh
RUN chmod 0755 /usr/local/bin/rotate.sh
ENV HOME=/tmp STEPPATH=/tmp/.step
USER 65532:65532
ENTRYPOINT ["/usr/local/bin/rotate.sh"]
