# Chocolatey package for nginx webserver on Windows

nginx [engine x] is an HTTP and reverse proxy server, a mail proxy server, and a generic TCP/UDP proxy server, originally written by Igor Sysoev.
This package provides an `nssm` Windows service wrapper for it which creates a standard Windows
service named `nginx` to manage the server.

#### N!B! This repository lists both nginx versions - stable and mainline:

* **Stable** and **mainline** only differ by version numbers. On command `choco install nginx-service` the stable will be installed. To access mainline version, you must use pre-release `--pre` switch or specify exact version number, which has `-mainline` appended to it.
* **Mainline** version might contain more edge features, whereas **stable** will be more prone to bugs. Both versions should receive critical security fixes. If you use this package for development and need to access latest features, go for mainline. If deployment is for longterm and unattended stability - choose stable.
* More info on [different nginx versions](https://www.nginx.com/blog/nginx-1-6-1-7-released/)

During installation `nginx-service` will create following directory structure:
```
C:/tools/nginx/
├── conf
│   ├── nginx.original.conf {conf file shipped with official .zip}
│   ├── nginx.conf          {tailored version of above file}
│   └── ...
├── conf.d
│   └── server.default.conf
├── html
│   └── index.html
├── logs
│   └── {Required}
└── temp
    └── {Required}
```

* Place your custom config files inside `conf.d`
* Conf to be included must follow naming pattern `server*.conf` where `*` is a wildcard
* Above allows config pattern where extra `.conf` files are included (and reused) manually from `server*.conf`, i.e. PHP location directive
* It is safe to edit/rename/remove default config files. They will be restored during upgrade only if `conf.d` is empty

Afterwards, you can start and stop the service with following commands: `nssm start nginx-service` and `nssm stop nginx-service`
On default, the service will autostart with Windows. To disable this use Services GUI console.

See the [nginx.org](https://nginx.org) for more detailed documentation.
