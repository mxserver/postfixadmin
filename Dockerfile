FROM alpine:3.12

LABEL description="PostfixAdmin is a web based interface used to manage mailboxes" \
      maintainer="Hardware <contact@meshup.net>"

ARG VERSION=3.2
ARG FULLVERSION=3.2.4

ARG SHA256_HASH="6d5b27012ce18b6dd257eb690d7d124781cf9ab44209511d49efb9ccd6ea27f1"

RUN echo "@community https://nl.alpinelinux.org/alpine/v3.11/community" >> /etc/apk/repositories \
 && apk -U upgrade \
 && apk add -t build-dependencies \
    ca-certificates \
    gnupg \
 && apk add \
    su-exec \
    dovecot \
    tini@community \
    php7@community \
    php7-phar \
    php7-fpm@community \
    php7-imap@community \
    php7-pgsql@community \
    php7-mysqli@community \
    php7-session@community \
    php7-mbstring@community \
 && cd /tmp \
 && PFA_TARBALL="postfixadmin-${FULLVERSION}.tar.gz" \
 && echo https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL} \
 && wget -q https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${VERSION}/${PFA_TARBALL} \
 && CHECKSUM=$(sha256sum ${PFA_TARBALL} | awk '{print $1}') \
 && if [ "${CHECKSUM}" != "${SHA256_HASH}" ]; then echo "ERROR: Checksum does not match!" && exit 1; fi \
 && mkdir /postfixadmin && tar xzf ${PFA_TARBALL} -C /postfixadmin && mv /postfixadmin/postfixadmin-$FULLVERSION/* /postfixadmin \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg /postfixadmin/postfixadmin-$FULLVERSION*

COPY bin /usr/local/bin
RUN chmod +x /usr/local/bin/*
EXPOSE 8888
CMD ["tini", "--", "run.sh"]
