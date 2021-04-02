# subversion server
build from soure code

# svnserve
svn protocol server (svn://) 

## applicaion path
    /usr/local/subversion 
## execute
    mkdir -p /var/svn
    docker run -it -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve obslib/subversion:svnserve-latest-0

## authentication
* password file
* sasl

## default
* repository path : /var/svn
* svn listening on port : 3690
* running user / group is root

## build source code list and version
### link lib
| **name** | **version** |
|:---:|:---:|
| apr | 1.7.0 |
| apr-util | 1.6.1 |
| expat |2 .2.10 |
| sqlite-amalgamation | 3.35.2 |
| zlib | 1.2.11 |

# project
* Where to file issues: https://github.com/obslib-net/docker-subversion/issues

