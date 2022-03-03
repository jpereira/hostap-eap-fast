# Sample showing problems in Hostap EAP-FAST/TLS1.{0,1,2} with FreeRADIUS v3.0.x/HEAD

## Build the image
```
$ git clone https://github.com/jpereira/hostap-eap-fast
$ cd hostap-eap-fast
$ docker build  . -f "Dockerfile" -t jpereiran/freeradius-eapfast-and-hostap
```

## Start the service

```
$ docker run -dti --hostname freeradius-eapfast-hostap --name freeradius-eapfast-hostap jpereiran/devbox-freeradius-server-hostap
```

FreeRADIUS server up & running using the user "bob" and pass "hello"

```
$ docker exec -it freeradius-eapfast-hostap radtest bob hello localhost 0 testing123
Sent Access-Request Id 143 from 0.0.0.0:43126 to 127.0.0.1:1812 length 73
	User-Name = "bob"
	User-Password = "hello"
	NAS-IP-Address = 172.17.0.2
	NAS-Port = 0
	Message-Authenticator = 0x00
	Cleartext-Password = "hello"
Received Access-Accept Id 143 from 127.0.0.1:1812 to 127.0.0.1:43126 length 32
	Reply-Message = "Hello, bob"
$
```

## hostap && eapol_test

Available "eapol_test" versions.

```
$ docker exec -it freeradius-eapfast-hostap eapol_test-2.9 -v
eapol_test v2.9-hostap_2_9
$ docker exec -it freeradius-eapfast-hostap eapol_test-2.10 -v
eapol_test v2.10-hostap_2_10
$ docker exec -it freeradius-eapfast-hostap eapol_test-main -v
eapol_test v2.11-devel-hostap_2_10-96-g08cd7a75b
$
```

Testing using 2.9

```
$ eapol_test-2.9 -c /root/eap-fast-tls-1.0.conf -s testing123
```

Testing using 2.10

```
$ eapol_test-2.10 -c /root/test-eap-fast.conf -s testing123
```

Using HEAD
```
.
```
