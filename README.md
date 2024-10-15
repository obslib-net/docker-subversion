# Subversion server
Subversion is an open source version control system. 
docker build from source code(latest stable packages).
latest version is 1.14.4

# Project
* Where to file issues: https://github.com/obslib-net/docker-subversion/issues
* Supported architectures: i386, amd64, arm32v7, arm64v8
* DockerHub: https://hub.docker.com/r/obslib/subversion



## build source code list and version
### dependency lib
| **name** | **version** | **image update** | **remark** |
|:---:|:---:|:---:|:---:|
| base-image          | -      | -              | debian:oldstable-slim |
| zlib                | 1.3.1  |   2024-01-19   | |
| expat               | 2.6.3  | **2024-10-15** | |
| libressl            | 3.8.4  |   2024-05-05   | httpd_svn only |
| apr                 | 1.7.5  | **2024-10-15** | |
| apr-util            | 1.6.3  |   2023-02-12   | |
| pcre2               | 10.44  | **2024-10-15** | httpd_svn only |
| httpd               | 2.4.62 | **2024-10-15** | httpd_svn only |
| sqlite-amalgamation | 3.46.1 | **2024-10-15** | |
| subversion          | 1.14.4 | **2024-10-15** | |

### subversion module version
  Subversion 1.10.x end of life.
  The currently available version is 1.14.4.

## applicaion path
* subversion : /usr/local/subversion
* httpd : /usr/local/httpd

## service type
| **service type** | **github branch(URL)**                                                                           | ** summary (protocol) **                  |
|:-----------------|:-------------------------------------------------------------------------------------------------|:------------------------------------------|
| svnserve         | [r0/svnserve/v1.14](https://github.com/obslib-net/docker-subversion/tree/r0/svnserve/v1.14)      | subversion standalone server (use svn://) |
| httpd_svn        | [r1/httpd_svn/v1.14](https://github.com/obslib-net/docker-subversion/tree/r1/httpd_svn/v1.14)    | httpd(apache) + mod_dav_svn (use http://) |

## container setting
* repository path : /var/svn/repos

### container setting - svnserve
* svn protocol listening on port : 3690 (repository url : svn://container)
* svnserve settings : /var/svn/repos/conf/svnserve.conf (svnserve)
* sasl2 link path: /var/run/saslauthd (use svnserve and sasl2)

### container setting - httpd_svn
* http protocol listening on port : 80 (repository url : http://container/repos)
* mod_dav_svn settings : /var/svn/repos/conf/httpd-svn.conf (mod_dav_svn path setting)
* mod_authz_svn settings : /var/svn/repos/conf/svnserve.conf (mod_authz_svn module AuthzSVNAccessFile directive)

# How to use this image
## use svn:// (svnserve)
### initial setting (create repos)
host side.
```
sudo mkdir -p /var/svn
docker pull obslib/subversion:svnserve-latest-0
docker run -it  --rm -v /var/svn:/var/svn --name svnserve obslib/subversion:svnserve-latest-0 /bin/bash
```

container side.
```
/usr/local/subversion/bin/svnadmin create /var/svn/repos
```

### execute
```
docker run -it -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve obslib/subversion:svnserve-latest-0
```

## use http:// (httpd_svn)
### initial setting (create repos)
* directory access permission : 33 (www-data user)

host side.
```
sudo mkdir -p /var/svn
docker pull obslib/subversion:httpd_svn-latest-1
docker run -it  --rm -v /var/svn:/var/svn --name httpd_svn obslib/subversion:httpd_svn-latest-1 /bin/bash
```

container side.
```
/usr/local/subversion/bin/svnadmin create /var/svn/repos
cp /usr/local/httpd/conf/httpd-svn.conf /var/svn/repos/conf/httpd-svn.conf
chown -R www-data:www-data /var/svn
```


### execute
```
docker run -it -p 80:80 -v /var/svn:/var/svn -d --name httpd_svn obslib/subversion:httpd_svn-latest-1
```

# container setting details
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
```
cd ${your/svn/work/dir}
```

2. create dir of host side
```
mkdir -p /var/svn
mkdir -p /var/svn/sasl2/var/run/saslauthd
mkdir -p /var/svn/sasl2/usr/lib/sasl2
mkdir -p /var/svn/sasl2/etc
```

3. create sasl Dockerfile(`./saslauthd/Dockerfile`)
```
mkdir ./saslauthd
vi ./saslauthd/Dockerfile
```
```
FROM ubuntu:bionic
RUN apt-get update && apt-get install -y --install-suggests \
    db5.3-sql-util                                          \
    sasl2-bin                                               \
 && apt-get -y clean                                        \
 && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/usr/sbin/saslauthd", "-d"]
CMD ["-a", "sasldb"]
```

4. get sasldb2
```
docker build -t "saslauthd" ./saslauthd
docker run -it --rm -d --name saslauthd-temp saslauthd
docker cp saslauthd-temp:/etc/sasldb2 /var/svn/sasl2/etc/sasldb2
docker stop saslauthd-temp
docker rmi saslauthd
```

5. create sasl svnserve settings file (`/var/svn/sasl2/usr/lib/sasl2/svn.conf`)
```
vi /var/svn/sasl2/usr/lib/sasl2/svn.conf
```
```
pwcheck_method: saslauthd
mech_list: PLAIN LOGIN
```

6. crearte svnserve settings file (auto create`/var/svn/repos`)
```
docker run -it --rm -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve-temp obslib/subversion:svnserve-latest-0  
docker stop svnserve-temp
```

7. comment off subversion conf use-sasl(`/var/svn/repos/conf/svnserve.conf`)
```
vi /var/svn/repos/conf/svnserve.conf
```
```
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
```

8. create docker compose file (./docker-compose.yml)
```
vi ./docker-compose.yml
```
```
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
```

##### start docker compose
```
cd ${your/svn/work/dir}
docker-compose up -d
```

##### user add
```
docker exec -it docker-saslauthd_saslauthd_1 bash
```
```
/usr/sbin/saslpasswd2 -c harry -u "My First Repository"
/usr/sbin/sasldblistusers2
/usr/sbin/testsaslauthd -u harry -p harryssecret -r "My First Repository"
```

##### stop docker compose
```
cd ${your/svn/work/dir}
docker-compose down
```

</details>


#### sasl settings example2 (use ldap)
<details>

* saslauthd : /var/run/saslauthd
* ldap-server : devldap

##### initial settings (only first time)
1. cd work dir
```
cd ${your/svn/work/dir}
```

2. create dir of host side
```
mkdir -p /var/svn
mkdir -p /var/svn/sasl2/var/run/saslauthd
mkdir -p /var/svn/sasl2/usr/lib/sasl2
```

3. crate sasl Dockerfile(`./saslauthd/Dockerfile`)
```
mkdir ./saslauthd
vi ./saslauthd/Dockerfile
```
```
FROM ubuntu:bionic
RUN apt-get update && apt-get install -y --install-suggests \
    sasl2-bin                                               \
 && apt-get -y clean                                        \
 && rm -rf /var/lib/apt/lists/*
COPY saslauthd.conf /etc/saslauthd.conf
ENTRYPOINT ["/usr/sbin/saslauthd", "-d"]
CMD ["-a", "ldap", "-O", "/etc/saslauthd.conf"]
```

4. crate sasl ldap search option file(`./saslauthd/saslauthd.conf`)
```
vi ./saslauthd/saslauthd.conf
```
(set up for your environment)
```
ldap_servers: ldap://devldap/
ldap_version: 3
ldap_bind_dn: cn=admin,dc=devhost,dc=devdomain
ldap_password: adminadmin
ldap_mech: md5
ldap_search_base: cn=Users,dc=devhost,dc=devdomain
ldap_filter: uid=%u
ldap_deref: search
```

5. crate sasl svnserve settings file (`/var/svn/sasl2/usr/lib/sasl2/svn.conf`)
```
vi /var/svn/sasl2/usr/lib/sasl2/svn.conf
```
```
pwcheck_method: saslauthd
mech_list: PLAIN LOGIN
```

6. crearte svnserve settings file (auto create`/var/svn/repos`)
```
docker run -it --rm -p 3690:3690 -v /var/svn:/var/svn -d --name svnserve-temp obslib/subversion:svnserve-latest-0
docker stop svnserve-temp
```

7. comment off subversion conf use-sasl(`/var/svn/repos/conf/svnserve.conf`)
```
vi /var/svn/repos/conf/svnserve.conf
```
```
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
```

8. create docker compose file (./docker-compose.yml)
```
vi ./docker-compose.yml
```
```
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
```

##### start docker compose
```
cd ${your/svn/work/dir}
docker-compose up -d
```

##### user auth check
```
docker exec -it docker-saslauthd_saslauthd_1 bash
```
```
/usr/sbin/testsaslauthd -u harry -p harryssecret
```

##### stop docker compose
```
cd ${your/svn/work/dir}
docker-compose down
```

</details>
</details>

## httpd - mod_dav_svn
<details>

http protocol server (use http://)

## authentication
* password file : /var/svn/repos/conf/.htpasswd
```
docker exec -it httpd_svn bash
```
```
/usr/local/httpd/bin/htpasswd  -c /var/svn/repos/conf/.htpasswd harry
New password: harryssecret
Re-type new password: harryssecret
Adding password for user harry
exit
```

* ldap (optional)
    please edit /var/svn/repos/conf/httpd-svn.conf
</details>
