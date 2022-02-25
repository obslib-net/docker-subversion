# Subversion server
Subversion is an open source version control system. 
docker build from source code(latest stable packages).
latest version is 1.14.1

# Project
* Where to file issues: https://github.com/obslib-net/docker-subversion/issues
* Supported architectures: amd64, arm64v8, arm32v7
* DockerHub: https://hub.docker.com/r/obslib/subversion

## build source code list and version
### dependency lib
| **name** | **version** | **remark** |
|:---:|:---:|:---:|
| zlib | 1.2.11 | |
| expat |2.4.6 | |
| openssl |1.1.1m | |
| apr | 1.7.0 | |
| apr-util | 1.6.1 | |
| pcre | 8.45 | |
| httpd | 2.4.52 | |
| sqlite-amalgamation | 3.38.0 | |
| subversion | 1.14.1 | |

## module applicaion path
    /usr/local/subversion : subversion home(svnserve) (use svn://)
    /usr/local/http : http home(httpd - mod_dav_svn) (use http://) (in preparation)

## container setting
* svn protocol listening on port : 3690 (repository url : svn://container)
* http protocol listening on port : 80 (repository url : http://container/repos)
* repository path : /var/svn/repos
* svnserve settings : /var/svn/repos/conf/svnserve.conf (use svnserve)
* sasl2 link path: /var/run/saslauthd (use svnserve and sasl2)
* http - mod_dav_svn settings : /var/svn/repos/conf/httpd-svn.conf (use http - mod_dav_svn)

# How to use this image
## use svn:// (svnserve)
### execute
    mkdir -p /var/svn
    docker run -it -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve obslib/subversion:svnserve-latest-0
## use http:// (http - mod_dav_svn)
### execute
    mkdir -p /var/svn
    docker run -it -p 80:80 -v /var/svn:/var/svn -d --name svnserve obslib/subversion:httpd-svn-latest-0


# container details
## svnserve
<details>

svn protocol server (svn://)

## authentication
* password file : /var/svn/repos/conf/passwd
* sasl (optional)

## optional
### sasl settings
please link /var/run/saslauthd


#### sasl settings example1 (use sasldb)
<details>

* saslauthd : /var/run/saslauthd
* sasldb : /etc/sasldb2

##### initial settings (only first time)
1. cd work dir

       cd ${your/svn/work/dir}

2. create dir of host side

       mkdir -p /var/svn
       mkdir -p /var/svn/sasl2/var/run/saslauthd
       mkdir -p /var/svn/sasl2/usr/lib/sasl2
       mkdir -p /var/svn/sasl2/etc

3. crate sasl Dockerfile(`./saslauthd/Dockerfile`)

       mkdir ./saslauthd
       vi ./saslauthd/Dockerfile

       FROM ubuntu:bionic
       RUN apt-get update && apt-get install -y --install-suggests \
           db5.3-sql-util                                          \
           sasl2-bin                                               \
        && apt-get -y clean                                        \
        && rm -rf /var/lib/apt/lists/*
       ENTRYPOINT ["/usr/sbin/saslauthd", "-d"]
       CMD ["-a", "sasldb"]

4. get sasldb2

       docker build -t "saslauthd" ./saslauthd
       docker run -it --rm                                             \
              -d --name saslauthd-temp saslauthd
       docker cp saslauthd-temp:/etc/sasldb2 /var/svn/sasl2/etc/sasldb2
       docker stop saslauthd-temp
       docker rmi saslauthd

5. crate sasl svnserve settings file (`/var/svn/sasl2/usr/lib/sasl2/svn.conf`)

       vi /var/svn/sasl2/usr/lib/sasl2/svn.conf

       pwcheck_method: saslauthd
       mech_list: PLAIN LOGIN

6. crearte svnserve settings file (auto create`/var/svn/repos`)

       docker run -it --rm -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve-temp obslib/subversion:svnserve-latest-0
       docker stop svnserve-temp

7. comment off subversion conf use-sasl(`/var/svn/repos/conf/svnserve.conf`)

       vi /var/svn/repos/conf/svnserve.conf

       ...
       [general]
       ...
       #password-db = passwd
       ...
       realm = My First Repository
       ...
       [sasl]
       ...
       use-sasl = true
       ...

8. create docker compose file (./docker-compose.yml)

       vi ./docker-compose.yml

       version: '3'
       
       services:
         saslauthd:
           build: ./saslauthd
           image: saslauthd
           volumes:
             - /var/svn/sasl2/etc/sasldb2:/etc/sasldb2
             - /var/svn/sasl2/var/run/saslauthd:/var/run/saslauthd
           restart: always
       
         svnserve:
           depends_on:
             - saslauthd
           image: obslib/subversion:svnserve-latest-0
           ports:
             - "3690:3690"
           volumes:
             - /var/svn:/var/svn
             - /var/svn/sasl2/var/run/saslauthd:/var/run/saslauthd
             - /var/svn/sasl2/usr/lib/sasl2/svn.conf:/usr/lib/sasl2/svn.conf
           restart: always


##### start docker compose

    cd ${your/svn/work/dir}
    docker-compose up -d

##### user add

    docker exec -it docker-saslauthd_saslauthd_1 bash

    /usr/sbin/saslpasswd2 -c harry -u "My First Repository"
    /usr/sbin/sasldblistusers2
    /usr/sbin/testsaslauthd -u harry -p harryssecret -r "My First Repository"

##### stop docker compose

    cd ${your/svn/work/dir}
    docker-compose down
</details>


#### sasl settings example2 (use ldap)
<details>

* saslauthd : /var/run/saslauthd
* ldap-server : devldap

##### initial settings (only first time)
1. cd work dir

       cd ${your/svn/work/dir}

2. create dir of host side

       mkdir -p /var/svn
       mkdir -p /var/svn/sasl2/var/run/saslauthd
       mkdir -p /var/svn/sasl2/usr/lib/sasl2

3. crate sasl Dockerfile(`./saslauthd/Dockerfile`)

       mkdir ./saslauthd
       vi ./saslauthd/Dockerfile

       FROM ubuntu:bionic
       RUN apt-get update && apt-get install -y --install-suggests \
           sasl2-bin                                               \
        && apt-get -y clean                                        \
        && rm -rf /var/lib/apt/lists/*
       COPY saslauthd.conf /etc/saslauthd.conf
       ENTRYPOINT ["/usr/sbin/saslauthd", "-d"]
       CMD ["-a", "ldap", "-O", "/etc/saslauthd.conf"]

4. crate sasl ldap search option file(`./saslauthd/saslauthd.conf`)

       vi ./saslauthd/saslauthd.conf
       (set up for your environment)

       ldap_servers: ldap://devldap/
       ldap_version: 3
       ldap_bind_dn: cn=admin,dc=devhost,dc=devdomain
       ldap_password: adminadmin
       ldap_mech: md5
       ldap_search_base: cn=Users,dc=devhost,dc=devdomain
       ldap_filter: uid=%u
       ldap_deref: search

5. crate sasl svnserve settings file (`/var/svn/sasl2/usr/lib/sasl2/svn.conf`)

       vi /var/svn/sasl2/usr/lib/sasl2/svn.conf

       pwcheck_method: saslauthd
       mech_list: PLAIN LOGIN

6. crearte svnserve settings file (auto create`/var/svn/repos`)

       docker run -it --rm -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve-temp obslib/subversion:svnserve-latest-0
       docker stop svnserve-temp

7. comment off subversion conf use-sasl(`/var/svn/repos/conf/svnserve.conf`)

       vi /var/svn/repos/conf/svnserve.conf

       ...
       [general]
       ...
       #password-db = passwd
       ...
       #realm = My First Repository
       ...
       [sasl]
       ...
       use-sasl = true
       ...

8. create docker compose file (./docker-compose.yml)

       vi ./docker-compose.yml

       version: '3'
       
       services:
         saslauthd:
           build: ./saslauthd
           image: saslauthd
           volumes:
             - /var/svn/sasl2/var/run/saslauthd:/var/run/saslauthd
           restart: always
       
         svnserve:
           depends_on:
             - saslauthd
           image: obslib/subversion:svnserve-latest-0
           ports:
             - "3690:3690"
           volumes:
             - /var/svn:/var/svn
             - /var/svn/sasl2/var/run/saslauthd:/var/run/saslauthd
             - /var/svn/sasl2/usr/lib/sasl2/svn.conf:/usr/lib/sasl2/svn.conf
           restart: always


##### start docker compose

    cd ${your/svn/work/dir}
    docker-compose up -d

##### user auth check

    docker exec -it docker-saslauthd_saslauthd_1 bash

    /usr/sbin/testsaslauthd -u harry -p harryssecret

##### stop docker compose

    cd ${your/svn/work/dir}
    docker-compose down
</details>
</details>

## httpd - mod_dav_svn
<details>

http protocol server (use http://)

## authentication
* password file : /var/svn/repos/conf/.htpasswd
* ldap (optional)

</details>
