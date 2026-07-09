ARG DEBIAN_DIST=bookworm
FROM debian:bookworm

ARG DEBIAN_DIST
ARG jujutsu_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION
ARG ARCH
ARG JUJUTSU_RELEASE

RUN mkdir -p /output/usr/bin
RUN mkdir -p /output/usr/share/doc/jujutsu
RUN mkdir -p /output/DEBIAN

COPY ${JUJUTSU_RELEASE}/jj /output/usr/bin/jj
COPY output/DEBIAN/control /output/DEBIAN/
COPY output/copyright /output/usr/share/doc/jujutsu/
COPY output/changelog.Debian /output/usr/share/doc/jujutsu/
COPY output/README.md /output/usr/share/doc/jujutsu/

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/usr/share/doc/jujutsu/changelog.Debian
RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/jujutsu/changelog.Debian
RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/control
RUN sed -i "s/jujutsu_VERSION/$jujutsu_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
RUN sed -i "s/SUPPORTED_ARCHITECTURES/$ARCH/" /output/DEBIAN/control

RUN dpkg-deb --build /output /jujutsu_${FULL_VERSION}.deb
