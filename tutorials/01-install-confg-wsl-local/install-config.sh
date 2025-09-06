#!/bin/bash

# Atualizar a lista dos pacotes
apt update -y 

# Aplicar as atualizações do pacotes
apt upgrade -y

# Instalar a lista dos idiomas/localidades, para ver o atual: sudo locale, para ver a lista disponivel: sudo locale -a
apt install locales -y

# Instalar a lista dos fuso-horários, para mostrar a lista: sudo timedatectl list-timezones
apt install tzdata

# Seta o timezone America/Cuiaba
timedatectl set-timezone America/Cuiaba

# Gerar o locale a baixo
locale-gen pt_BR.UTF-8

# Setar o locale/localização (precisa reiniciar a máquina, sudo reboot)
update-locale LANG="pt_BR.UTF-8" LANGUAGE="pt_BR"

# Instala o firebird
apt install firebird3.0-server

# Instala as dependências do delphi
apt install -yy joe wget p7zip-full curl openssh-server build-essential zlib1g-dev libcurl4-gnutls-dev libncurses5

# Baixa a lib especifica do python (usado para o debug do paserver)
apt install -y libpython3.10

# Instala a lib do firebird
apt install -y libfbclient2

# Configura a lib do firebird
ln -s /usr/lib/x86_64-linux-gnu/libfbclient.so.2 /usr/lib/x86_64-linux-gnu/libfbclient.so

# Baixa o paserver 22 para delphi 11.3
curl https://altd.embarcadero.com/releases/studio/22.0/113/LinuxPAServer22.0.tar.gz -o /opt/PAServer22.0.tar.gz

# Criar pasta base para aplicações
mkdir /apps/

# Descompacta o paserver
tar -xf /opt/PAServer22.0.tar.gz -C /apps/

# Ajusta lib do python para o debug do paserver
mv /apps/PAServer-22.0/lldb/lib/libpython3.so /apps/PAServer-22.0/lldb/lib/libpython3.so_ && ln -s /lib/x86_64-linux-gnu/libpython3.10.so.1 /apps/PAServer-22.0/lldb/lib/libpython3.so

# Criar pasta para guardar os bancos de dados firebird
mkdir -p /firebird/3.0/data

# Mudar o dono para o grupo firebird
chown firebird:firebird /firebird/



