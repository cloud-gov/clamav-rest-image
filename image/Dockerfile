ARG base_image

FROM ${base_image}

ARG CLAMAV_REST_VERSION="20250705"
ARG GO_VERSION="1.24.4"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tzdata logrotate netcat wget

# Install golang
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

# Compile clamav-rest
WORKDIR /go/src

RUN mkdir -p /go/src/clamav-rest && \
    wget https://github.com/ajilach/clamav-rest/archive/refs/tags/${CLAMAV_REST_VERSION}.tar.gz && \
    tar -C /go/src -xzf ${CLAMAV_REST_VERSION}.tar.gz && \
    rm ${CLAMAV_REST_VERSION}.tar.gz 

WORKDIR /go/src/clamav-rest-${CLAMAV_REST_VERSION}
    
RUN go mod tidy && \
    go build -v && \
    cp clamav-rest /usr/bin


COPY clamavlogrotate /etc/logrotate.d/clamav

# Set timezone 
ENV TZ=America/New_York

ADD ./server.* /etc/ssl/clamav-rest/

# Install ClamAV

RUN apt-get install -y clamav clamav-base clamav-daemon clamav-freshclam libclamunrar9 

COPY entrypoint.sh /usr/bin/

COPY conf/ /etc/clamav/

RUN mkdir -p /run/clamav && \
    chown -R clamav:clamav /run/clamav && \
    chown -R clamav:clamav /etc/clamav && \
    chown -R clamav:clamav /var/lib/clamav && \
    chown -R clamav:clamav /var/log/clamav 

RUN freshclam --quiet --no-dns

RUN chown -R clamav:clamav /run/clamav && \
    chown -R clamav:clamav /etc/clamav && \
    chown -R clamav:clamav /var/lib/clamav && \
    chown -R clamav:clamav /var/log/clamav 

ENV PORT=9000
ENV SSL_PORT=9443
ENV MAX_SCAN_SIZE=100M
ENV MAX_FILE_SIZE=25M
ENV MAX_RECURSION=16
ENV MAX_FILES=10000
ENV MAX_EMBEDDEDPE=10M
ENV MAX_HTMLNORMALIZE=10M
ENV MAX_HTMLNOTAGS=2M
ENV MAX_SCRIPTNORMALIZE=5M
ENV MAX_ZIPTYPERCG=1M
ENV MAX_PARTITIONS=50
ENV MAX_ICONSPE=100
ENV MAX_RECONNECT_TIME=30
ENV PCRE_MATCHLIMIT=100000
ENV PCRE_RECMATCHLIMIT=2000
ENV SIGNATURE_CHECKS=2
ENV ALLOW_ORIGINS=*

USER clamav

ENTRYPOINT [ "entrypoint.sh" ]
