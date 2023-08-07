
FROM debian:oldstable AS build
COPY build_target.sh /usr/local/src/build_target.sh
COPY get_deps.sh /usr/local/src/get_deps.sh
RUN chmod 755 /usr/local/src/build_target.sh
RUN chmod 755 /usr/local/src/get_deps.sh
RUN /usr/local/src/build_target.sh

COPY entrypoint_svnserve.sh /usr/local/subversion/bin/entrypoint.sh
RUN chmod 755 /usr/local/subversion/bin/entrypoint.sh

COPY httpd.conf /usr/local/httpd/conf/httpd.conf
COPY httpd-svn.conf /usr/local/httpd/conf/httpd-svn.conf
COPY entrypoint_httpd.sh /usr/local/httpd/bin/entrypoint.sh
RUN chmod 755 /usr/local/httpd/bin/entrypoint.sh

FROM ubuntu:bionic AS install
COPY --from=build /usr/local/subversion /usr/local/subversion
COPY --from=build /usr/local/httpd /usr/local/httpd

ENV LD_LIBRARY_PATH /usr/local/subversion/lib:/usr/local/httpd/lib:$LD_LIBRARY_PATH

RUN set -eux                                                                  \
 && apt-get update                                                            \
 && apt-get install -y                                                        \
        libldap-2.4-2                                                         \
        libsasl2-2                                                            \
        supervisor                                                            \
 && apt-get -y clean                                                          \
 && rm -rf /var/lib/apt/lists/*                                               \
 && groupadd -r --gid=999 svn                                                 \
 && useradd -r -g svn --uid=999 --home-dir=/var/svn svn                       \
 && mkdir -p /var/svn                                                         \
 && chown -R svn:svn /var/svn                                                 \
 && ldconfig

COPY supervisord-svn.conf /etc/supervisor/conf.d/svn.conf

EXPOSE 80 3690

CMD ["/usr/bin/supervisord"]
