# FROM i386/ubuntu:bionic-20190307
FROM ubuntu:bionic-20190307

ENV DEBIAN_FRONTEND noninteractive

# docker.exe build . -t deshaker
# docker.exe run -it -v  M:/devwork/ps-avisynth-deshake/video:/video deshaker bash

# http://avisynth.nl/index.php/HOWTO:_AviSynth_video_processing_with_WINE
# https://ubuntuforums.org/showthread.php?t=1333264
# https://github.com/cdrx/docker-nsis/blob/master/Dockerfile
# https://nsis.sourceforge.io/Docs/Chapter4.html#silent
# https://forum.winehq.org/viewtopic.php?t=103
# http://alesnosek.com/blog/2015/07/04/running-wine-within-docker/
# https://askubuntu.com/questions/14465/installing-or-faking-a-x11-session
# https://stackoverflow.com/questions/16296753/can-you-run-gui-applications-in-a-docker-container
# http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/

# ENV WINEARCH wine32
# ENV WINEDEBUG fixme-all
# ENV WINEPREFIX /wine

WORKDIR /app

# Only for amd64
RUN dpkg --add-architecture i386

RUN apt-get update -y \
  && apt-get install -y \
  unzip \
  p7zip-full \
  wine32 \
  p7zip-rar \
  wget \
  wget \
  xvfb \
  ca-certificates \
  snapd

# Only works on amd64
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update -y \
  && apt-get install -y powershell

RUN apt-get clean

# RUN md5sum /tmp/packages/VirtualDub-1.10.4.zip > /tmp/md5/files.md5 \
#   && md5sum /tmp/packages/ffms2-2.23.1-msvc.7z >> /tmp/md5/files.md5 \
#   && md5sum /tmp/packages/Deshaker31.zip >> /tmp/md5/files.md5 \
#   && md5sum /tmp/packages/AviSynth_260.exe >> /tmp/md5/files.md5

# VOLUME /tmp/md5/

COPY ./packages/ /tmp/packages/
COPY ./md5/files.md5 /tmp/_.md5
COPY ./deshake.template.* ./

RUN md5sum -c /tmp/_.md5

RUN unzip /tmp/packages/VirtualDub-1.10.4.zip -d ./virtualdub \
  && 7z x /tmp/packages/ffms2-2.23.1-msvc.7z -o/tmp/ \
  && unzip /tmp/packages/Deshaker31.zip -d ./
  
RUN nohup xvfb-run -a wine /tmp/packages/AviSynth_260.exe /S /D=C:\Program Files\AviSynth

RUN find /root/.wine/drive_c/Program\ Files/AviSynth/ | grep .dll$ \
  && find /root/.wine/drive_c/ | grep avisynth.dll$
  # && 7z x -y /tmp/packages/AviSynth_260.exe -o/tmp/avisynth

RUN mv -f /tmp/ffms2-2.23.1-msvc/x86/* /root/.wine/drive_c/Program\ Files/AviSynth/plugins/ \
  && mv -f ./Deshaker.vdf /root/.wine/drive_c/Program\ Files/AviSynth/ \
  && cp -rf ./virtualdub /root/.wine/drive_c/Program\ Files/

VOLUME [ "/video" ]

RUN mkdir -p /root/.wine/drive_c/video

COPY ./deshake.ps1 ./deshake.ps1

#  cp -rf /video/* /root/.wine/drive_c/video/ && pwsh deshake.ps1 MVI_2126.MOV

# RUN wget https://downloads.sourceforge.net/project/avisynth2/AviSynth%202.6/AviSynth%202.6.0/AviSynth_260.exe

# RUN  winecfg &> /dev/null \
# && find /root/.wine/drive_c/

# RUN wineprefixcreate
# RUN wine /tmp/packages/AviSynth_260.exe /S \
  # && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
# /D=C:\Program Files\AviSynth

CMD cp -rf /video/* /root/.wine/drive_c/video/ && pwsh deshake.ps1 MVI_2126.MOV