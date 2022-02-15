
FROM ubuntu:bionic AS build
COPY build_target.sh /usr/local/src/build_target.sh
COPY get_deps.sh /usr/local/src/get_deps.sh
RUN chmod 755 /usr/local/src/build_target.sh
RUN chmod 755 /usr/local/src/get_deps.sh
RUN /usr/local/src/build_target.sh

COPY httpd.conf /usr/local/httpd/conf/httpd.conf
COPY httpd-svn.conf /usr/local/httpd/conf/httpd-svn.conf
COPY entrypoint_httpd.sh /usr/local/httpd/bin/entrypoint.sh
COPY entrypoint_svnserve.sh /usr/local/subversion/bin/entrypoint.sh
RUN chmod 755 /usr/local/httpd/bin/entrypoint.sh
RUN chmod 755 /usr/local/subversion/bin/entrypoint.sh

FROM ubuntu:bionic AS install
COPY --from=build /usr/local/httpd /usr/local/httpd
COPY --from=build /usr/local/subversion /usr/local/subversion

RUN set -eux;                                                                 \
    apt-get update;                                                           \
    apt-get install -y                                                        \
        libsasl2-2                                                            \
        libldap-2.4-2;                                                         \
    apt-get -y clean;                                                         \
    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH /usr/local/httpd/lib:/usr/local/subversion/lib:$LD_LIBRARY_PATH
RUN ldconfig

RUN set -eux; \
    groupadd -r --gid=999 subversion; \
    useradd -r -g subversion --uid=999 --home-dir=/var/svn subversion; \
    mkdir -p /var/svn; \
    chown -R subversion:subversion /var/svn

EXPOSE 80 3690

CMD ["/usr/local/httpd/bin/entrypoint.sh"]
