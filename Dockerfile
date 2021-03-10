FROM ubuntu:bionic AS build-env
COPY build_target.sh /usr/local/src/build_target.sh
COPY get_deps.sh /usr/local/src/get_deps.sh
RUN chmod 755 /usr/local/src/build_target.sh
RUN chmod 755 /usr/local/src/get_deps.sh
RUN /usr/local/src/build_target.sh

FROM ubuntu:bionic
COPY --from=build-env /usr/local/subversion /usr/local/subversion/
COPY entrypoint.sh /usr/local/subversion/bin/entrypoint.sh
RUN chmod 755 /usr/local/subversion/bin/entrypoint.sh
EXPOSE 3690
CMD ["/usr/local/subversion/bin/entrypoint.sh"]
