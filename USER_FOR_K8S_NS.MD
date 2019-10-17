#### Создание пользователя с возможностью деплоя в выбранный NS

_На основе статьи https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/#use-case-1-create-user-with-limited-namespace-access_

```
Username:   ci
Group:      developers
```

##### Создание NS

`kubectl create namespace test`


##### Credentials

Генерируем ключ

`openssl genrsa -out ci.key 2048`

Генерируем запрос сертификата

`openssl req -new -key ci.key -out ci.csr -subj "/CN=ci/O=developers"`

Если видим ошибку `Can't load /home/vagrant/.rnd into RNG`, то в настройках ssl комментируем строчку с RANDFILE `sudo vi /etc/ssl/openssl.cnf`

Проверяем наличие **ca.crt** и **ca.key** в директории **/etc/kubernetes/pki/** или в **~/.minikube/** если экспериментируем с minikube

Подписываем серт на 500 дней

`openssl x509 -req -in ci.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ci.crt -days 500`

Сохраняем ci.crt и ci.key в безопасном месте или подготавливаем для передачи пользователю

```
mkdir ~/.certs
mv ci.crt ~/.certs/
mv ci.key ~/.certs/
```

Подготавливаем контекст для kubectl

Что бы получить имя кластера нужно выполнить `kubectl config current-context`

```
kubectl config set-credentials ci --client-certificate=.certs/ci.crt  --client-key=.certs/ci.key
kubectl config set-context ci-context --cluster=cluster.local --namespace=test --user=ci
``` 

Далее для получения ресурсов нужно будет либо настроить контекст по умолчанию либо добвалять к командам параметр 

`kubectl --context=ci-context get pods`

Выполнив запрос выше получим ошибку

_Error from server (Forbidden): pods is forbidden: User "ci" cannot list resource "pods" in API group "" in the namespace "test"_

тк не настроены роли для пользователя **ci**.

##### Создание роли для управления деплойментами

Создаем файл role-deployment-manager.yaml

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: test
  name: deployment-manager
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]
```

Выполняем команду

`kubectl create -f role-deployment-manager.yaml`

##### Связывание роли с пользователем

Создаем файл rolebinding-deployment-manager.yaml

```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: deployment-manager-binding
  namespace: test
subjects:
- kind: User
  name: ci
  apiGroup: ""
roleRef:
  kind: Role
  name: deployment-manager
  apiGroup: ""
```

Выполняем команду

`kubectl create -f rolebinding-deployment-manager.yaml`

##### Тестируем

```
kubectl --context=ci-context run --image bitnami/dokuwiki mydokuwiki
kubectl --context=ci-context get pods
```
```
kubectl --context=ci-context get pods --namespace=default
```