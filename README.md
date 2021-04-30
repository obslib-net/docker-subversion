# subversion server
build from soure code

# svnserve
svn protocol server (svn://)

## applicaion path
    /usr/local/subversion

## execute
    mkdir -p /var/svn
    docker run -it -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve obslib/subversion:svnserve-latest

# project
* DockerHub: https://hub.docker.com/r/obslib/subversion
* Where to file issues: https://github.com/obslib-net/docker-subversion/issues
