`Update the role arn's for autoscaler and external-dns before kubectl apply command`

For clusterissuer, Please install the cert-manager and nginx-ingress first. You can find the innstructions in `helm/Readme.md` file.

# Install autoscaler

```
kubectl apply -f autoscaler.yaml -n kube-system
```

# Install external-dns

```
kubectl apply -f externaldns.yaml -n external-dns
```

# Install clusterissuer

```
kubectl apply -f clusterissuer
```
