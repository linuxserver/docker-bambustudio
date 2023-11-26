FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BAMBUSTUDIO_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=BambuStudio \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    firefox-esr \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-qt5 \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    libgstreamer1.0 \
    libgstreamer-plugins-bad1.0 \
    libgstreamer-plugins-base1.0 \
    libwebkit2gtk-4.0-37 \
    libwx-perl && \
  echo "**** install bambu studio from appimage ****" && \
  if [ -z ${BAMBUSTUDIO_VERSION+x} ]; then \
    BAMBUSTUDIO_VERSION=$(curl -sX GET "https://api.github.com/repos/bambulab/BambuStudio/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  RELEASE_URL=$(curl -sX GET "https://api.github.com/repos/bambulab/BambuStudio/releases/latest"     | awk '/url/{print $4;exit}' FS='[""]') && \
  DOWNLOAD_URL=$(curl -sX GET "${RELEASE_URL}" | awk '/browser_download_url.*ubuntu/{print $4;exit}' FS='[""]') && \
  cd /tmp && \
  curl -o \
    /tmp/bambu.app -L \
    "${DOWNLOAD_URL}" && \
  chmod +x /tmp/bambu.app && \
  ./bambu.app --appimage-extract && \
  mv squashfs-root /opt/bambustudio && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
