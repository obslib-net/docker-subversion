
FROM debian:oldstable AS build

ARG BUILD_TARGET=svnserve
ARG BUILD_VERSION=v0.0

COPY build_template/source_version.sh                                   /usr/local/src/source_version.sh
COPY build_template/source_get.sh                                       /usr/local/src/source_get.sh
COPY ${BUILD_TARGET}/${BUILD_VERSION}/source_version_custom.sh          /usr/local/src/source_version_custom.sh
COPY ${BUILD_TARGET}/build_target.sh                                    /usr/local/src/build_target.sh

RUN  chmod 755 /usr/local/src/*.sh                                      \
  && /usr/local/src/build_target.sh

COPY ${BUILD_TARGET}/entrypoint_svnserve.sh                             /usr/local/subversion/bin/entrypoint.sh
RUN  chmod 755 /usr/local/subversion/bin/entrypoint.sh

FROM debian:oldstable-slim AS install
COPY --from=build /usr/local/subversion                                 /usr/local/subversion

RUN set -eux                                                                  \
 && apt-get update                                                            \
 && apt-get install -y                                                        \
        libsasl2-2                                                            \
 && apt-get -y clean                                                          \
 && rm -rf /var/lib/apt/lists/*                                               \
 && mkdir -p /var/svn                                                         \
 && ldconfig

ENV LD_LIBRARY_PATH=/usr/local/subversion/lib

EXPOSE 3690

CMD ["/usr/local/subversion/bin/entrypoint.sh"]

