# SPIRE intermediate-CA rotator toolbox: step + step-kms-plugin (KMS signing) + kubectl,
# distroless, multi-arch (amd64/arm64). No shell -> CronJob drives single-command containers.
ARG STEP_VERSION=0.30.6
ARG KMS_PLUGIN_VERSION=0.17.0
ARG KUBECTL_VERSION=1.36.1

FROM --platform=$BUILDPLATFORM debian:12-slim AS builder
ARG STEP_VERSION KMS_PLUGIN_VERSION KUBECTL_VERSION TARGETARCH
RUN set -eux; \
    apt-get update; apt-get install -y --no-install-recommends ca-certificates curl; \
    dpkg --add-architecture "${TARGETARCH}"; apt-get update; \
    apt-get download "libpcsclite1:${TARGETARCH}"; dpkg-deb -x libpcsclite1_*.deb /tmp/pcsc; \
    mkdir -p /out; \
    curl -sSL "https://github.com/smallstep/cli/releases/download/v${STEP_VERSION}/step_linux_${TARGETARCH}.tar.gz" | tar xz -C /tmp; \
    install -m0755 "/tmp/step_linux_${TARGETARCH}/bin/step" /out/step; \
    curl -sSL "https://github.com/smallstep/step-kms-plugin/releases/download/v${KMS_PLUGIN_VERSION}/step-kms-plugin_${KMS_PLUGIN_VERSION}_linux_${TARGETARCH}.tar.gz" | tar xz -C /tmp; \
    install -m0755 "$(find /tmp -name step-kms-plugin -type f | head -1)" /out/step-kms-plugin; \
    curl -sSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" -o /out/kubectl; \
    chmod 0755 /out/kubectl; \
    cp -L /tmp/pcsc/usr/lib/*-linux-gnu/libpcsclite.so.1 /out/libpcsclite.so.1

FROM gcr.io/distroless/base-debian12:nonroot
COPY --from=builder /out/step /usr/local/bin/step
COPY --from=builder /out/step-kms-plugin /usr/local/bin/step-kms-plugin
COPY --from=builder /out/kubectl /usr/local/bin/kubectl
COPY --from=builder /out/libpcsclite.so.1 /usr/local/lib/libpcsclite.so.1
ENV HOME=/tmp STEPPATH=/tmp/.step LD_LIBRARY_PATH=/usr/local/lib
USER 65532:65532
