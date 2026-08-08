
FROM debian:oldstable AS build
COPY build_target.sh /usr/local/src/build_target.sh
COPY get_deps.sh /usr/local/src/get_deps.sh
RUN chmod 755 /usr/local/src/build_target.sh
RUN chmod 755 /usr/local/src/get_deps.sh
RUN /usr/local/src/build_target.sh

COPY entrypoint_svnserve.sh /usr/local/subversion/bin/entrypoint.sh
RUN chmod 755 /usr/local/subversion/bin/entrypoint.sh

FROM debian:oldstable AS install
COPY --from=build /usr/local/subversion /usr/local/subversion

ENV LD_LIBRARY_PATH /usr/local/subversion/lib:$LD_LIBRARY_PATH

RUN set -eux                                                                  \
 && apt-get update                                                            \
 && apt-get install -y                                                        \
        libsasl2-2                                                            \
 && apt-get -y clean                                                          \
 && rm -rf /var/lib/apt/lists/*                                               \
 && mkdir -p /var/svn                                                         \
 && ldconfig

EXPOSE 3690

CMD ["/usr/local/subversion/bin/entrypoint.sh"]

