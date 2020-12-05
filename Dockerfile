FROM timstephens24/ubuntu

# set version label
ARG BUILD_DATE
ARG VERSION
ARG JELLYFIN_RELEASE
LABEL build_version="stephens.cc version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="timstephens24"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN echo "**** install jellyfin *****" \
  && curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - \
  && echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal main' > /etc/apt/sources.list.d/jellyfin.list \
  && echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal unstable' >> /etc/apt/sources.list.d/jellyfin.list \
  #&& if [ -z ${JELLYFIN_RELEASE+x} ]; then \
  #    JELLYFIN="jellyfin"; \
  #  else \
  #    JELLYFIN="jellyfin=${JELLYFIN_RELEASE}"; \
  #  fi \
  #&& apt-get install -y --no-install-recommends at i965-va-driver intel-media-va-driver-non-free ${JELLYFIN} jellyfin-ffmpeg jellyfin-server jellyfin-web libfontconfig1 libfreetype6 libssl1.1 mesa-va-drivers \
  && apt update \
  && apt install -y --no-install-recommends jellyfin-ffmpeg \
  && cd /tmp \
  && curl -o /tmp/jellyfin.deb -L \
    https://repo.jellyfin.org/releases/server/debian/stable/meta/jellyfin_10.7.0~rc1_all.deb \
  && curl -o /tmp/jellyfin-server.deb -L \
    https://repo.jellyfin.org/releases/server/debian/stable/server/jellyfin-server_10.7.0~rc1_amd64.deb \
  && curl -o /tmp/jellyfin-web.deb -L \
    https://repo.jellyfin.org/releases/server/debian/stable/web/jellyfin-web_10.7.0~rc1_all.deb \
  && dpkg -i jellyfin-web_10.7.0~rc1_all.deb \
  && dpkg -i jellyfin-server_10.7.0~rc1_amd64.deb \
  && dpkg -i jellyfin_10.7.0~rc1_all.deb \
  && echo "**** cleanup ****" \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
