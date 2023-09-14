# Attribution
# Source: https://github.com/haizaar/docker-python-minimal
# This Dockerfile is super-slim python/nginx-unit build 
# Official nginx-unit builds weights ~1000Mb and uses Debian as base image
# This build will weight 120Mb. 
# Still WIP


FROM --platform=linux/amd64 python:3.11-alpine as builder

RUN apk add --no-cache binutils py3-pip
RUN find /usr/local -name '*.so' | xargs strip -s
RUN pip uninstall -y pip
RUN set -ex RUN  \
    cd /usr/local/lib/python*/config-*-x86_64-linux-gnu/ RUN  \
    rm -rf *.o *.a
RUN rm -rf /usr/local/lib/python*/ensurepip
RUN rm -rf /usr/local/lib/python*/idlelib
RUN rm -rf /usr/local/lib/python*/distutils/command
RUN rm -rf /usr/local/lib/python*/lib2to3
RUN rm -rf /usr/local/lib/python*/__pycache__/*
RUN find /usr/local/include/python* -not -name pyconfig.h -type f -exec rm {} \;
RUN find /usr/local/bin -not -name 'python*' \( -type f -o -type l \) -exec rm {} \;
RUN rm -rf /usr/local/share/*
RUN apk del binutils
RUN pip3 install pipenv

# ------
FROM --platform=linux/amd64 alpine:latest as final
# ------
ENV LANG C.UTF-8
RUN apk add --no-cache libbz2 expat libffi-dev xz-libs sqlite-libs readline ca-certificates unit-python3 curl unit
COPY --from=builder /usr/local/ /usr/local/
WORKDIR /usr/src

# ------
RUN addgroup --gid 1024 volume_group
RUN adduser unit volume_group
# ------

# COPY ["----PATH TO NGINX-UNIT-CONFIGURATION.JSON", "/docker-entrypoint.d/"] 
COPY ["/docker/docker-files/template_storage/docker-entrypoint.sh", "/usr/local/bin/"]
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 80
CMD ["unitd", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]
