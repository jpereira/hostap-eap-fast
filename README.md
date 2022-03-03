# Sample of FreeRADIUS & hostap/eapol_test

Testing Hostap EAP-FAST/TLS1.{0,1,2} with FreeRADIUS v3.0.x/HEAD

## Build the image
```
$ git clone https://github.com/jpereira/hostap-eap-fast
$ cd hostap-eap-fast
$ docker build  . -f "Dockerfile" -t jpereiran/freeradius-eapfast-and-hostap
```

## Start the service

```
$ docker run -dti --hostname docker-freeradius-eapfast-hostap --name docker-freeradius-eapfast-hostap jpereiran/docker-freeradius-eapfast-hostap
```

Get in container.

```
$ docker exec -it docker-freeradius-eapfast-hostap /bin/bash
root@docker-freeradius-eapfast-hostap:~#
```

FreeRADIUS server up & running using the user "bob" and pass "hello"

```
root@docker-freeradius-eapfast-hostap:~# radtest bob hello localhost 0 testing123
Sent Access-Request Id 143 from 0.0.0.0:43126 to 127.0.0.1:1812 length 73
	User-Name = "bob"
	User-Password = "hello"
	NAS-IP-Address = 172.17.0.2
	NAS-Port = 0
	Message-Authenticator = 0x00
	Cleartext-Password = "hello"
Received Access-Accept Id 143 from 127.0.0.1:1812 to 127.0.0.1:43126 length 32
	Reply-Message = "Hello, bob"
root@docker-freeradius-eapfast-hostap:~#
```

## hostap && eapol_test

Available "eapol_test" versions.

```
root@docker-freeradius-eapfast-hostap:~# eapol_test-2.10 -v
eapol_test v2.10-hostap_2_10
root@docker-freeradius-eapfast-hostap:~# eapol_test-main -v
eapol_test v2.11-devel-hostap_2_10-96-g08cd7a75b
root@docker-freeradius-eapfast-hostap:~#
```

Testing using 2.10

```
$ eapol_test-2.10 -c /root/eap-fast-tls-1.0.conf -s testing123 | tail
$ eapol_test-2.10 -c /root/eap-fast-tls-1.1.conf -s testing123 | tail
$ eapol_test-2.10 -c /root/eap-fast-tls-1.2.conf -s testing123 | tail
```

Testing using "main" (HEAD)

```
$ eapol_test-main -c /root/eap-fast-tls-1.0.conf -s testing123
$ eapol_test-main -c /root/eap-fast-tls-1.1.conf -s testing123
$ eapol_test-main -c /root/eap-fast-tls-1.2.conf -s testing123
```
