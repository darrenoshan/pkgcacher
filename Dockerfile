FROM fedora:latest

RUN dnf -y update && dnf -y install apt-cacher-ng  && dnf clean all

RUN set -uex ; \
    mv /etc/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf.original; \
    mv /etc/apt-cacher-ng/security.conf /etc/apt-cacher-ng/security.conf.original; \
    mkdir -p  /var/run/apt-cacher-ng/ && touch /var/run/apt-cacher-ng/socket ; \
    ln -sf /dev/stdout /var/log/apt-cacher-ng/apt-cacher.log; \
    ln -sf /dev/stderr /var/log/apt-cacher-ng/apt-cacher.err;

RUN mv /usr/libexec/apt-cacher-ng/userinfo.html /usr/libexec/apt-cacher-ng/userinfo.html.original ; \
    INFO="/usr/libexec/apt-cacher-ng/userinfo.html" ; \
    echo "<html><body><html>" >> "$INFO" ; \
    echo "echo 'Acquire::http { Proxy \"myhostname.ltd\"; }' > /etc/apt/apt.conf.d/proxy" >> "$INFO" ; \ 
    echo "echo 'proxy=IP:PORT' >> /etc/dnf/dnf.conf" >> "$INFO"

COPY acng.conf /etc/apt-cacher-ng/

RUN setcap cap_net_bind_service=+ep /usr/sbin/apt-cacher-ng

EXPOSE 8080

RUN groupadd -g 10001 fedora && \
   useradd -u 10000 -g fedora fedora && \
   chown -R fedora:fedora /var/cache/apt-cacher-ng/ /var/run/apt-cacher-ng/ /etc/apt-cacher-ng/ 

USER fedora:fedora

VOLUME ["/var/cache/apt-cacher-ng"]

ENTRYPOINT ["/usr/sbin/apt-cacher-ng"]

CMD ["-c","/etc/apt-cacher-ng/","-vvvv"]
