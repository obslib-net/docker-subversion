
FROM debian:oldstable AS build
COPY build_target.sh /usr/local/src/build_target.sh
COPY get_deps.sh /usr/local/src/get_deps.sh
RUN chmod 755 /usr/local/src/build_target.sh
RUN chmod 755 /usr/local/src/get_deps.sh
RUN /usr/local/src/build_target.sh

