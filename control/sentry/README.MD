Sentry устанавливаем из helm: https://github.com/helm/charts/tree/master/stable/sentry

```
helm install --name sentry \
  --set filestore.filesystem.persistence.existingClaim="sentry-postgresql" \
  --set ingress.enabled=true \
  --set ingress.path="/sentry" \
  --wait \
  --namespace sentry \
    stable/sentry
```

```
helm install --name sentry \
  --set ingress.enabled=true \
  --set ingress.path="/sentry" \
  --wait \
  --namespace sentry \
    stable/sentry
```

helm del --purge sentry
kubectl delete pvc sentry-postgresql -n sentry

