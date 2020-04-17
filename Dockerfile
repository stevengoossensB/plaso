FROM alpine:latest
LABEL maintainer="Steven Goossens"
LABEL description="Plaso image"

ENV DEBIAN_FRONTEND noninteractive

# *********** Installing Prerequisites ***************
# -qq : No output except for errors
RUN apk update && apk upgrade -f && apk add -f \
  wget \
  sudo \
  nano \
  curl \
  build-base \
  bash
CMD ["/sbin/my_init"]

ARG TZ=Europe/London

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV CFLAGS="$CFLAGS -D_GNU_SOURCE"

# Install dependencies
RUN apk update \
  && apk add --no-cache python3 \
             python3-dev \
             py3-pip \
             py3-setuptools \
             bash  
RUN apk add --no-cache xz-dev \
             zeromq \
             libffi-dev \
             py3-lz4 \
             py3-openssl \
             \
  # Install dependencies
  && apk add --virtual .temp \
                       build-base \
                       git \
                       linux-headers \
                       tzdata \
                       \
  && rm -rf /var/cache/apk/* \
  \
  # Add new user
  && adduser -D plaso \
  \
  # Set up timezone
  && cp /usr/share/zoneinfo/$TZ /etc/localtime \
  && echo $TZ > /etc/timezone \
  \
  # Install plaso
  && git config --global http.sslVerify false && git clone --branch=master \
               --depth=1 \
               https://github.com/log2timeline/plaso.git \
               /plaso \
  && cd /plaso \
  && pip3 install --upgrade pip \
  && pip3 install -r requirements.txt \
  && pip3 install elasticsearch \
  && python3 setup.py install 
  && apk del .temp \
  && rm -rf /root/.cache 

VOLUME /data

USER plaso
