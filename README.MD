Что еще нужно изучить.
- добавление воркера
- удаление воркера
- конфигурацию HA (3 ноды etcd, пару мастеров и несколько воркеров)
- настройка сетей




Это нужно для развертывания в Vagrant ubuntu 16.04
    export LC_ALL="en_US.UTF-8"
    export LC_CTYPE="en_US.UTF-8"
    sudo dpkg-reconfigure locales


Подготовка к инсталляции

Копируем пример инвентаря

cp -rfp inventory/sample inventory/mycluster

Что бы построить файл инвентаря hosts.yml нужно будет установить python3 и установить зависимости
pip3 install ruamel_yaml==0.15.97  --user

Конструируем hosts.yml
declare -a IPS=( 192.168.111.11 192.168.111.12 192.168.111.13)
CONFIG_FILE=inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
Желательно после создания проверить hosts.yml и внести правки по вкусу

Запускаем создание кластера
ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml  --private-key=~/.ssh/id_rsa

или вот так если вручную править инвентарь
ansible-playbook -i inventory/mycluster/inventory.ini --become --become-user=root cluster.yml   --private-key=~/.ssh/id_rsa


-----
После выполнения Ansible сделать на мастерноде

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

далее управление kubernetes доступно с использованием kubectl

Выполняем 
kubectl get nodes

Если видим что-то подобное 

NAME    STATUS   ROLES    AGE   VERSION
node1   Ready    master   47m   v1.14.1
node2   Ready    master   47m   v1.14.1
node3   Ready    <none>   46m   v1.14.1

Значит все хорошо

Если нужно управлять с другой машины нужно будет скопировать .kube/config в домашний каталог.

export KUBERNETES_MASTER=http://192.168.111.11:8080


----------------
Добавление ноды.

Нужно запустить еще одну ноду.
В inventory/mycluster/hosts.yml добавить данные новой ноды
и выполнить запуск 
ansible-playbook -i inventory/mycluster/hosts.yml scale.yml -b -v --private-key=~/.ssh/id_rsa


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

-----------------

Установка плагинов 

В Kubespray предусмотрены настройки для инсталляции дополнительных плагинов
inventory/mycluster/group_vars/k8s-cluster/addons.yml
