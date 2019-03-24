FROM i386/ubuntu:bionic-20190307

ENV DEBIAN_FRONTEND noninteractive

# docker.exe build . -t deshaker
# docker.exe run -it -v  M:/devwork/ps-avisynth-deshake/md5:/tmp/md5/ deshaker bash

# http://avisynth.nl/index.php/HOWTO:_AviSynth_video_processing_with_WINE
# https://ubuntuforums.org/showthread.php?t=1333264
# https://github.com/cdrx/docker-nsis/blob/master/Dockerfile
# https://nsis.sourceforge.io/Docs/Chapter4.html#silent
# https://forum.winehq.org/viewtopic.php?t=103

ENV WINEARCH win32
ENV WINEDEBUG fixme-all
ENV WINEPREFIX /wine

WORKDIR /app

# VOLUME /tmp/md5/

COPY ./packages/ /tmp/packages/
COPY ./md5/ /tmp/md5/files.md5

RUN apt-get update -qy \
  && apt-get install --no-install-recommends -qfy \
  unzip \
  p7zip-full \
  wine32 \
  p7zip-rar \
  wget \
  # wine32-development \ 
  # wine-development \
  wget \
  xvfb \
  # md5sum \
  ca-certificates \
  && apt-get clean

# RUN md5sum /tmp/packages/VirtualDub-1.10.4.zip > /tmp/md5/files.md5 \
#   && md5sum /tmp/packages/ffms2-2.23.1-msvc.7z >> /tmp/md5/files.md5 \
#   && md5sum /tmp/packages/Deshaker31.zip >> /tmp/md5/files.md5 \
#   && md5sum /tmp/packages/AviSynth_260.exe >> /tmp/md5/files.md5

RUN md5sum -c /tmp/md5/files.md5

RUN unzip /tmp/packages/VirtualDub-1.10.4.zip -d ./virtualdub \
  && 7z x /tmp/packages/ffms2-2.23.1-msvc.7z -o/tmp/ \
  && unzip /tmp/packages/Deshaker31.zip -d /tmp/deshaker \
  # && nohup xvfb-run -a wine /tmp/packages/AviSynth_260.exe /S  /D=C:\Program Files\AviSynth
  && 7z x -y /tmp/packages/AviSynth_260.exe -o/tmp/avisynth

# RUN wget https://downloads.sourceforge.net/project/avisynth2/AviSynth%202.6/AviSynth%202.6.0/AviSynth_260.exe

# RUN  winecfg &> /dev/null \
# && find /root/.wine/drive_c/

# RUN wineprefixcreate
# RUN wine /tmp/packages/AviSynth_260.exe /S \
  # && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
# /D=C:\Program Files\AviSynth

CMD echo 'exiting....'