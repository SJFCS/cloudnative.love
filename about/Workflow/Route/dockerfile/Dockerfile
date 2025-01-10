FROM alpine:latest

LABEL maintainer="Izumiko <yosoro@outlook.com>"

ARG TARGETOS TARGETARCH TARGETVARIANT MIHOMO_VERSION

ENV MIHOMO_CONFIG_DIRECTORY=/root/.config/mihomo

EXPOSE 7890 9090

RUN apk add --update --no-cache ca-certificates \
    && rm -rf /var/cache/apk/*

RUN if [ "${TARGETARCH}" = "amd64" ]; \
then wget -qO mihomo.gz https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-${TARGETOS}-amd64-compatible-${MIHOMO_VERSION}.gz \
    && gzip -d mihomo.gz && chmod +x mihomo \
    && mv mihomo /usr/local/bin/mihomo; \
else wget -qO mihomo.gz https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-${TARGETOS}-${TARGETARCH}${TARGETVARIANT}-${MIHOMO_VERSION}.gz \
    && gzip -d mihomo.gz && chmod +x mihomo \
    && mv mihomo /usr/local/bin/mihomo; \
fi

ENTRYPOINT /usr/local/bin/mihomo -d $MIHOMO_CONFIG_DIRECTORY