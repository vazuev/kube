Как настроить автоматический деплой приложения в kubernetes


1. Производим установку kubernetes как написано в README.MD

2. Создаем namespace для приложения

    `kubectl create ns demo`

3. Создаем сервисный аккаунт

    `kubectl create serviceaccount mysaname -n demo`

4. Получаем данные сервисного аккаунта

    `kubectl get serviceaccounts mysaname -o yaml -n demo`

    `kubectl get secrets mysaname-token-.... -n demo -o yaml`

    Данные из `ca.crt` копируем/создаем в защищенную переменную окружения `KUBE_CA`
    
    Данные из `token` копируем/создаем в защищенную переменную окружения `KUBE_CA`

5. Create the following Role and RoleBinding objects to allow the serviceaccount to deploy new versions of our app

Create file **role.yaml** and assign namespace (demo) & role name (deploy)

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
namespace: demo
name: deploy
rules:
- apiGroups: ["extensions", "apps"]
  resources: ["deployments"]
  verbs: ["get", "update", "patch", "create"]
```


Create a file **rolebinding.yaml** and assign serviceaccount (mysaname), namespace(demo) & role(deploy)
    
```
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
name: deploy-role-binding
namespace: demo
subjects:
- kind: ServiceAccount
name: mysaname
namespace: demo
roleRef:
kind: Role
  name: deploy
  apiGroup: rbac.authorization.k8s.io
```

Run

```
kubectl apply -f rolebinding.yaml
kubectl apply -f role.yaml
```

Пример bitbacket pipeline

```
# -----
options:
docker: true
pipelines:
 branches:
   demo:
    - step:
# set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION as environment variables 
        name: Push Build in ECR
        deployment: test    # set to test, staging or production
        # trigger: manual  # uncomment to have a manual step
        image: atlassian/pipelines-awscli
        script:
         - eval $(aws ecr get-login --no-include-email --region ap-southeast-1)
         - export BUILD_ID=$BITBUCKET_BRANCH_$BITBUCKET_COMMIT_$BITBUCKET_BUILD_NUMBER         - docker build -t ${AWS_REGISTRY_URL}:$BUILD_ID .
         - docker push ${AWS_REGISTRY_URL}:$BUILD_ID
    
    - step:
        name: Deploy to Kubernetes
        deployment: staging   # set to test, staging or production
        # trigger: manual  # uncomment to have a manual step
        image: atlassian/pipelines-kubectl
        script:
# Configure kubectl
              - export BUILD_ID=$BITBUCKET_BRANCH_$BITBUCKET_COMMIT_$BITBUCKET_BUILD_NUMBER
              - export IMAGE_NAME=${AWS_REGISTRY_URL}:$BUILD_ID
              - echo $KUBE_TOKEN | base64 -d > ./kube_token
              - echo $KUBE_CA | base64 -d > ./kube_ca
              - kubectl config set-cluster $KUBE_CLUSTER --server=$KUBE_SERVER --certificate-authority="$(pwd)/kube_ca"
              - kubectl config set-credentials $KUBE_SA --token="$(cat./kube_token)"
              - kubectl config set-context $KUBE_NAMESPACE --cluster=$KUBE_CLUSTER --user=$KUBE_SA
              - kubectl config use-context $KUBE_NAMESPACE
              - kubectl set image deployment/webapp-deployment $ECR_REPONAME=$IMAGE_NAME -n $KUBE_NAMESPACE
```