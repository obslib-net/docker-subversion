
FROM debian:oldstable AS build

ARG BUILD_TARGET=httpd_svn
ARG BUILD_VERSION=undefined

COPY build_template/source_version.sh                                   /usr/local/src/source_version.sh
COPY build_template/source_get.sh                                       /usr/local/src/source_get.sh
COPY ${BUILD_TARGET}/${BUILD_VERSION}/source_version_custom.sh          /usr/local/src/source_version_custom.sh
COPY ${BUILD_TARGET}/build_target.sh                                    /usr/local/src/build_target.sh

RUN  chmod 755 /usr/local/src/*.sh                                      \
  && /usr/local/src/build_target.sh

COPY ${BUILD_TARGET}/entrypoint_svnserve.sh                             /usr/local/subversion/bin/entrypoint.sh
RUN  chmod 755 /usr/local/subversion/bin/entrypoint.sh

COPY ${BUILD_TARGET}/httpd.conf                                         /usr/local/httpd/conf/httpd.conf
COPY ${BUILD_TARGET}/httpd-svn.conf                                     /usr/local/httpd/conf/httpd-svn.conf
COPY ${BUILD_TARGET}/entrypoint_httpd.sh                                /usr/local/httpd/bin/entrypoint.sh
RUN chmod 755 /usr/local/httpd/bin/entrypoint.sh

FROM debian:oldstable-slim AS install
COPY --from=build /usr/local/subversion                                 /usr/local/subversion
COPY --from=build /usr/local/httpd                                      /usr/local/httpd

RUN set -eux                                                                  \
 && apt-get update                                                            \
 && apt-get install -y                                                        \
        libsasl2-2                                                            \
        libldap-2.5-0                                                         \
 && apt-get -y clean                                                          \
 && rm -rf /var/lib/apt/lists/*                                               \
 && mkdir -p /var/svn                                                         \
 && ldconfig

ENV LD_LIBRARY_PATH=/usr/local/subversion/lib:/usr/local/httpd/lib

EXPOSE 80 3690

CMD ["/usr/local/httpd/bin/entrypoint.sh"]

