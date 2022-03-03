# Sample showing problems in Hostap EAP-FAST/TLS1.{0,1,2} with FreeRADIUS v3.0.x/HEAD

## Build the image
```
$ git clone https://github.com/jpereira/hostap-eap-fast
$ cd hostap-eap-fast
$ docker build  . -f "Dockerfile" -t jpereiran/freeradius-eapfast-and-hostap
```

## Start the service

```
docker run -dti --hostname freeradius-eapfast-hostap --name freeradius-eapfast-hostap jpereiran/freeradius-eapfast-and-hostap
```

## Test eapol_test

```
.
```

```
.
```