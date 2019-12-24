### Устанавливаем jenkins

~~Передварительно убеждаемся что создан storageClass local-path (https://github.com/rancher/local-path-provisioner)~~
При установке k8s нужно в аддонах указать local_path_provisioner_enabled: true

#### С файлом values.yaml

`helm install --name jenkins -f values.yaml --namespace jenkins stable/jenkins`

#### Длинно:

```
helm install --name jenkins \
   --set master.ingress.enabled=true \
   --set master.adminUser="admin" \
   --set master.adminPassword="admin" \
   --set master.ingress.apiVersion="networking.k8s.io/v1beta1" \
   --set master.ingress.path="/jenkins" \
   --set master.jenkinsUriPrefix="/jenkins" \
   --set persistence.storageClass="local-path" \
   --namespace jenkins stable/jenkins
```

#### Коротко:

```
helm install --name jenkins \
   --set master.adminUser="admin" \
   --set master.adminPassword="admin" \
   --set persistence.storageClass="local-path" \
   --namespace jenkins stable/jenkins
```

Что бы удалить релиз нужно выполнить `helm del --purge jenkins`

Проверяем что все ок

`kubectl get pod -n jenkins`

```
NAME                       READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
jenkins-74bc4dd9b5-z4zv7   0/1     Pending   0          32s   <none>   <none>   <none>           <none>
```

Проверяем что под запустился

`kubectl describe pod -n jenkins jenkins-54999f6c7f-b6hcr`

Проверяем что сервис работает 

`kubectl describe svc jenkins -n jenkins`

Проверяем ingress

`kubectl get ing -n jenkins`

Получаем логин пользователя

`kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-user}" | base64 --decode; echo`

получить пароль 

`kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode; echo`

Добавляем ingress для jenkins

`kubectl apply -f jenkins-ingress-rull.yaml`


Если нужно поиграть с параметрами чарта helm

```
helm upgrade jenkins \
   --set master.ingress.enabled=true \
   --set master.adminUser="admin" \
   --set master.adminPassword="admin" \
   --set master.ingress.apiVersion="networking.k8s.io/v1beta1" \
   --set master.ingress.path="/jenkins" \
   --set master.jenkinsUriPrefix="/jenkins" \
   --set persistence.storageClass="local-path" \
   --namespace jenkins stable/jenkins
```

```
helm install --name jenkins \
   --set master.ingress.enabled=true \
   --set master.adminUser="admin" \
   --set master.adminPassword="admin" \
   --set master.ingress.apiVersion="networking.k8s.io/v1beta1" \
   --set master.ingress.path="/jenkins" \
   --set master.jenkinsUriPrefix="/jenkins" \
   --set persistence.storageClass="local-path" \
   --namespace jenkins stable/jenkins
```