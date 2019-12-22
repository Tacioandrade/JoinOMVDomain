#!/bin/bash
# Criado: Tácio de Jesus Andrade - tacio@multiti.com.br
# Data: 22-12-2019
# Função: Script que Integra o OpenMediaVault 3, 4 ou 5 no Domínio
# Informações: Antes de executar esse script verifique se o DNS server é o Domain Controller e se pinga para o dominio.local 

echo "Informe o nome do domínio Ex. EXEMPLO.LOCAL: " ; read DOMAIN
echo "Informe o nome do seu Domain Controller Ex. dc01.exemplo.local: " ; read DC
echo "Informe o usuário que será usado como Domain Admin para integrar ao domínio: " ; read DOMAINUSER
# Instala os pacotes necessários
apt-get install krb5-user krb5-config winbind samba samba-common smbclient cifs-utils libpam-krb5 libpam-winbind libnss-winbind

# Backup arquivo Kerberos
cp /etc/krb5.conf /etc/krb5.conf.ori

# Corrige arquivo Kerberos
echo "[logging]
Default = FILE:/var/log/krb5.log

[libdefaults]
ticket_lifetime = 24000
clock-skew = 300
default_realm = $DOMAIN
dns_lookup_realm = true
dns_lookup_kdc = true

[realms]
MULTITI.LOCAL = {
kdc = $DC
default_domain = `echo $DOMAIN | tr 'A-Z' 'a-z'`
admin_server = $DC
}

[domain_realm]
.`echo $DOMAIN | tr 'A-Z' 'a-z'` = $DOMAIN
`echo $DOMAIN | tr 'A-Z' 'a-z'` = $DOMAIN

[login]
krb4_convert = true
krb4_get_tickets = false" > /etc/krb5.conf

# Corrige o problema de resolução de DNS e faz os usuários do winbind poderem logar
cp /etc/nsswitch.conf /etc/nsswitch.conf.ori
echo "passwd:         compat winbind
group:          compat winbind
shadow:         files
gshadow:        files

# hosts:          files mdns4_minimal [NOTFOUND=return] dns myhostname
hosts:          dns files mdns4_minimal [NOTFOUND=return] myhostname
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis" > /etc/nsswitch.conf

# Testa se a conexão com o DC está ok
echo "


Digite a senha de Administrador do domínio para checar a viabilidade de integrar ao domínio" 
kinit $DOMAINUSER
klist

# Adicione isso no Extras do samba para integrar ao domínio
echo "Habilite o samba e adicione isso no campo Extras do samba do OpenMediaVault pela interface gráfica:

security = ads
realm = `echo $DOMAIN`
client signing = yes
client use spnego = yes
kerberos method = secrets and keytab
obey pam restrictions = yes
protocol = SMB3
netbios name = `hostname | cut -d '.' -f1`
password server = *
encrypt passwords = yes
winbind uid = 10000-20000
winbind gid = 10000-20000
winbind enum users = yes
winbind enum groups = yes
winbind use default domain = yes
winbind refresh tickets = yes
idmap config `echo $DOMAIN | cut -d '.' -f1` : backend  = rid
idmap config `echo $DOMAIN | cut -d '.' -f1` : range = 1000-9999
Idmap config *:backend = tdb 
idmap config *:range = 85000-86000 
template shell    = /bin/sh
lanman auth = no
ntlm auth = yes
client lanman auth = no
client plaintext auth = No
client NTLMv2 auth = Yes" > /tmp/smb.tmp
cat /tmp/smb.tmp

# Requisita o Enter para continuar a configuração
echo "


Após fazer a alteração, digite Enter: " ; read ENTER

# Integra ao domínio
echo "


Digite a senha de Administrador do domínio para integrar o OpenMediaVault ao DC" 
net ads join -U $DOMAINUSER
net ads testjoin

# Reinicia os serviços
/etc/init.d/smbd restart
/etc/init.d/winbind restart

# Lista os usuários do domínio
sleep 3
wbinfo -u

echo "Reinicie o servidor e verifique se os usuários foram adicionados a interface gráfica com sucesso!"
