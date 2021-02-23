FROM ubuntu:bionic AS ubuntu-svn-build
COPY build.sh /usr/local/src/.
RUN  /usr/local/src/build.sh
COPY docker_exec_svnserve.sh /usr/local/subversion/docker_exec_svnserve.sh


FROM ubuntu:bionic
COPY --from=ubuntu-svn-build /usr/local/subversion /usr/local/subversion/
COPY docker_exec_svnserve.sh /usr/local/subversion/bin/docker_exec_svnserve.sh
EXPOSE 3690
CMD ["/usr/local/subversion/bin/docker_exec_svnserve.sh"]
