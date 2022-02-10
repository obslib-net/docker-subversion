# project
* Where to file issues: https://github.com/obslib-net/docker-subversion/issues
* DockerHub: https://hub.docker.com/r/obslib/subversion
* Supported architectures: amd64, arm64v8

# subversion server
build from source code
latest version is 1.14.1

# svnserve
svn protocol server (svn://)

## execute
    mkdir -p /var/svn
    docker run -it -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve obslib/subversion:svnserve-latest-0

## authentication
* password file
* sasl (optional)

## default
* repository path : /var/svn
* svn listening on port : 3690

## build source code list and version
### dependency lib
| **name** | **version** | **remark** |
|:---:|:---:|:---:|
| zlib | 1.2.11 | |
| apr | 1.7.0 | |
| apr-util | 1.6.1 | |
| expat |2.4.4 | |
| sqlite-amalgamation | 3.37.2 | |

## applicaion path
    /usr/local/subversion

# optional
## sasl settings
please link /var/run/saslauthd

### sasl settings example1 (use sasldb)
<details>

* repo : /var/svn
* saslauthd : /var/run/saslauthd
* sasldb : /etc/sasldb2

#### initial settings (only first time)
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
       docker rmi svnserve-temp

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


#### start docker compose

    cd ${your/svn/work/dir}
    docker-compose up -d

#### user add

    docker exec -it docker-saslauthd_saslauthd_1 bash

    /usr/sbin/saslpasswd2 -c harry -u "My First Repository"
    /usr/sbin/sasldblistusers2
    /usr/sbin/testsaslauthd -u harry -p harryssecret -r "My First Repository"

#### stop docker compose

    cd ${your/svn/work/dir}
    docker-compose down
</details>

### sasl settings example2 (use ldap)
<details>

* repo : /var/svn
* saslauthd : /var/run/saslauthd
* ldap-server : devldap

#### initial settings (only first time)
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
       docker rmi svnserve-temp

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


#### start docker compose

    cd ${your/svn/work/dir}
    docker-compose up -d

#### user auth check

    docker exec -it docker-saslauthd_saslauthd_1 bash

    /usr/sbin/testsaslauthd -u harry -p harryssecret

#### stop docker compose

    cd ${your/svn/work/dir}
    docker-compose down
</details>
</section>
