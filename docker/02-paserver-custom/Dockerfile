FROM desenvolmcn/ubuntu-delphi:22.04

RUN apt update && apt install -yy libpython3.10

ADD https://altd.embarcadero.com/releases/studio/22.0/113/LinuxPAServer22.0.tar.gz /home/downloads/

RUN mkdir -p /apps/paserver

RUN tar -xf /home/downloads/LinuxPAServer22.0.tar.gz -C /apps/paserver/

WORKDIR /apps/paserver/PAServer-22.0

RUN mv lldb/lib/libpython3.so lldb/lib/libpython3.so_ && ln -s /lib/x86_64-linux-gnu/libpython3.10.so.1 lldb/lib/libpython3.so

EXPOSE 64211
EXPOSE 8080

CMD [ "./paserver", "-password=123"]
