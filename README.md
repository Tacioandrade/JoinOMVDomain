# Script melhorado
Pessoal o Eduardo Jonck um grande amigo pegou o meu script e fez várias melhoras, ele agora é em Dialog o que facilita a compreensão, faz as edições do arquivo smb.conf automaticamente, etc. O meu script ficará aqui disponível para caso alguém queira, porém recomendo agora usar o dele:

https://github.com/eduardojonck/scripts/blob/master/Linux/Shell/Join_OMV_to_AD_1.0

# JoinOMVDomain
Script para integrar o OpenMediaVault 3, 4 e 5 no domínio

Com esse script você conseguirá adicionar o OpenMediaVault em um Domínio Samba4 ou Windows Server, no Windows Server foi homologado no 2008R2 e 2012R2 (as VMs que tinha aqui), porém acredito que funcionará com qualquer versão do Windows Server.

# Utilização
Para fazer uso do script, só faça o download do arquivo, dê permissão de execução e execute-o como root ou sudo:


wget https://raw.githubusercontent.com/Tacioandrade/JoinOMVDomain/master/JoinDC.sh


chmod +x JoinDC.sh


./JoinDC.sh

Após executar o script siga o passo a passo e reinicie o OpenMediaVault, após reiniciar, só ir olhar no menu de Usuários da ferramenta e verá que todos os usuários já foram adicionados!
