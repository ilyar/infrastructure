apiVersion: cert-manager.io/v1
kind: ${kind}
metadata:
  name: ${name}
spec:
  acme:
    privateKeySecretRef:
      name: ${name}
    server: ${server}
    solvers:
      - http01:
          ingress:
            class: nginx
