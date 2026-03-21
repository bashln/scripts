clear&&
sleep 2s
echo "#--------------------Iniciando atualização do sistema--------------------#"
echo ""

#sincroniza os repositórios do Manjaro Linux.
sudo pacman -Syy --noconfirm

#sincroniza os repositórios/procura por atualização
sudo pacman -Syu --noconfirm

#sincronização total/procura por atualização.
sudo pacman -Syyu --noconfirm

