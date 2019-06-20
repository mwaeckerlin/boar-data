Track Boar Data Changes
=======================

Docker Image to Checkout Boar Session and Checkin Changes, can be used as docker volume to provide access to boar data for non-boar aware applications.

Configuration
-------------

Environment:
 - `BOAR_USER`: name of the user to access boar server, defaut: `boar`
 - `BOAR_HOST`: host name of the boar server, default: `boar`
 - `BOAR_PORT`: ssh port of the boar server, default: `22`
 - `BOAR_REPO`: url of the boar repository, where the variables `BOAR_USER` and `BOAR_HOST` are replaced by the content of the variables above, default: `boar+ssh://BOAR_USER@BOAR_HOST/boar`
 - `SSH_PUBKEY`: optional ssh public key for the `BOAR_USER` to access `BOAR_HOST`
 - `SSH_PRIVKEY`: optional ssh private key for the `BOAR_USER` to access `BOAR_HOST`
 - `SESSIONS`: list of sessions to checkout, default: detected from `boar list`
 - `TIMEOUT`: timeout in seconds for the `inotifywait` that waits for file system changes; if `inotifywait` does not work, this is the maximum time you have to wait for updates (checkin of changed files, checkout chanues from server), default: `600` (10min)

Example
-------

See [mwaeckerlin/openldap](https://github.com/mwaeckerlin/openldap) or [my blog](https://marc.wäckerlin.ch/computer/setup-openldap-server-in-docker) for details on setting up an OpenLDAP server.

```bash
docker run --name openldap ... mwaeckerlin/openldap # see documenation of mwaeckerlin/openldap
docker run -d --restart unless-stopped \
              --name boar \
              -p 2222:22/tcp \
              --volume /srv/volumes/boar/boar:/boar \
              --volume /srv/volumes/boar/etc/ssh:/etc/ssh \
              --volume /srv/volumes/boar/home:/home \
              --link openldap:ldap \
              -e 'LDAPBASEUSERDN=ou=person,ou=people' \
              -e 'LDAPBASEGROUPDN=ou=group' \
              -e 'SSH_PUBKEY=ssh-rsa XXX...SOME_CHARACTERS_HERE...XXX root@520b4516155f' \
              -e 'LDAPBINDDN=cn=boar-bind,ou=system,ou=people' \
              -e 'LDAPBINDPW=secret' \
              mwaeckerlin/boar
docker run -d --restart unless-stopped \
              --name boar-data \
              --volume /srv/volumes/boar-data:/data \
              -e 'SESSIONS=documents images movies' \
              -e 'SSH_PUBKEY=ssh-rsa XXX...SOME_CHARACTERS_HERE...XXX root@520b4516155f' \
              -e 'SSH_PRIVKEY=-----BEGIN RSA PRIVATE KEY-----\
Several.Lines.Of.Secret.Numbers.And.Letters.And.Other.Characters\
Several.Lines.Of.Secret.Numbers.And.Letters.And.Other.Characters\
Several.Lines.Of.Secret.Numbers.And.Letters.And.Other.Characters\
Several.Lines.Of.Secret.Numbers.And.Letters.And.Other.Characters\
-----END RSA PRIVATE KEY-----' \
              mwaeckerlin/boar-data
```

The checked out data of the  boar sessions is then available in `/srv/volumes/boar-data`.
