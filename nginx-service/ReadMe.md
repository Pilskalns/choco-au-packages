# Chocolatey package for nginx webserver on Windows

nginx [engine x] is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server, originally written by Igor Sysoev.
This package provides an `nssm` Windows service wrapper for it which creates a standard Windows
service named `nginx` to manage the server.

#### N!B! Upgrading from nginx-service 1.6.2.1 and below it will have new default configuration location.

It may be disappointing, but here's few reasons why:

* Writing inside previous `C:/ProgramData/nginx` requires editor to be opened with Administrator privileges
* Changing to new directory allow for optimistic migration from 1.6.2.1 to 1.12.2
* 1.6.2.1 is a quite old and I believe most of users have already found another way for newer nginx. Those who dont, probably also wont bother updating to newer
* `C:/tools/nginx` is on par with other web-related choco packages


During installation `nginx-service` will create following directory structure:
```
C:/tools/nginx/
├── conf
│   ├── nginx.conf
│   └── ...
├── conf.d
│   ├── default.conf
│   └── d0n3.ws.conf.sample {Bonus file, read content}
├── html
│   └── index.html
├── logs
│   └── {Required}
└── temp
    └── {Required}
```

See the [nginx.org](https://nginx.org) for more detailed documentation.
