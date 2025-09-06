FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=pt_BR.UTF-8
ENV LANGUAGE=pt_BR:pt
ENV LC_ALL=pt_BR.UTF-8
ENV TZ=America/Cuiaba

RUN apt update && apt install -yy \
                  locales tzdata joe wget p7zip-full curl \
                  openssh-server build-essential zlib1g-dev libcurl4-gnutls-dev libncurses5 \
                  libfbclient2

# Ref: https://docwiki.embarcadero.com/RADStudio/Sydney/en/Connect_to_Firebird_(FireDAC)
RUN ln -s /usr/lib/x86_64-linux-gnu/libfbclient.so.2 /usr/lib/x86_64-linux-gnu/libfbclient.so

RUN locale-gen pt_BR.UTF-8

COPY ./openssl.cnf /etc/ssl/


