Что еще нужно изучить.
- добавление воркера
- удаление воркера
- конфигурацию HA (3 ноды etcd, пару мастеров и несколько воркеров)
- настройка сетей





export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
sudo dpkg-reconfigure locales

wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
sudo python3 /tmp/get-pip.py
pip install --user pipenv
pip3 install --user pipenv

sudo apt-get install python3-pip

echo "PATH=$HOME/.local/bin:$PATH" >> ~/.profile
source ~/.profile
whereis pip

git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
pip3 install --upgrade cryptography --user
sudo pip3 install -r requirements.txt --user



cp -rfp inventory/sample inventory/mycluster


Что бы построить файл инвентаря hosts.yml нужно будет установить python3 и установить зависимости

declare -a IPS=( 192.168.111.11 192.168.111.12 192.168.111.13)
CONFIG_FILE=inventory/mycluster/hosts.yml python contrib/inventory_builder/inventory.py ${IPS[@]}
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml  --private-key=~/.ssh/id_rsa

или вот так если вручную править инвентарь
ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root cluster.yml   --private-key=~/.ssh/id_rsa


-----
После выполнения Ansible сделать на мастерноде

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


export KUBERNETES_MASTER=http://192.168.111.11:8080


----------------
Добавление ноды.

Нужно запустить еще одну ноду.
В inventory/mycluster/hosts.yml добавить данные новой ноды
и выполнить запуск 

ansible-playbook -i inventory/mycluster/hosts.yml scale.yml -b -v --private-key=~/.ssh/private_key


----------------
Удаление ноды.
Добавить ноды в hosts.yml в раздел kube-node
Выполнить что бы удалить все ноды:
ansible-playbook -i inventory/mycluster/hosts.yml remove-node.yml -b -v \
    --private-key=~/.ssh/private_key

Что бы удалить конкретные нужно выполнить: 
ansible-playbook -i inventory/mycluster/hosts.yml remove-node.yml -b -v \
  --private-key=~/.ssh/private_key \
  --extra-vars "node=nodename,nodename2"

Где nodename и nodename2 имена нод описанные в hosts.yml


