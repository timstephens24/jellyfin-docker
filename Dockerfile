FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

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
  && apt update \
  && apt install -y --no-install-recommends wget iproute2 beignet-opencl-icd jq ocl-icd-libopencl1 udev unrar wget \
  && COMP_RT_RELEASE=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/latest" | jq -r '.tag_name') \
  && COMP_RT_URLS=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/tags/${COMP_RT_RELEASE}" | jq -r '.body' | grep wget | sed 's|wget ||g') \
  && mkdir -p /opencl-intel \
  && for i in ${COMP_RT_URLS}; do \
      i=$(echo ${i} | tr -d '\r'); \
      echo "**** downloading ${i} ****"; \
      curl -o "/opencl-intel/$(basename ${i})" -L "${i}"; \
    done \
  && curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - \
  && echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal main' > /etc/apt/sources.list.d/jellyfin.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends jellyfin-ffmpeg jellyfin \
  && echo "**** cleanup ****" \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /opencl-intel

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
