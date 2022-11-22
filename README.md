# Cartographer

## Prerequisites

```sh
# install
kapp deploy -a cert-manager -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml -y
kubectl create namespace cartographer-system
kapp deploy -a cartographer -f https://github.com/vmware-tanzu/cartographer/releases/latest/download/cartographer.yaml -y
kapp deploy -a kpack -f https://github.com/pivotal/kpack/releases/download/v0.7.2/release-0.7.2.yaml -y
kapp deploy -a tekton -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.30.0/release.yaml -y
flux install --namespace=flux-system --network-policy=false --components=source-controller
kapp deploy -a kc -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml -y
kapp deploy -a knative-serving \
    -f https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-crds.yaml \
    -f https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-core.yaml \
    -f https://github.com/knative/net-kourier/releases/download/knative-v1.8.0/kourier.yaml -y
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
kapp deploy -a tekton-git-cli -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-cli/0.2/git-cli.yaml -y
kapp deploy -a tekton-dashboard -f https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml -y

# uninstall
kapp delete -a kc -y
flux uninstall --namespace=flux-system
kapp delete -a tekton -y
kapp delete -a kpack -y
kapp delete -a cartographer -y
k delete ns/cartographer
kapp delete -a cert-manager -y
```

## Installation

### App Operator

The supply chain, templates, etc.

```sh
# install
kapp deploy -a package-supply-chain-app-operator -f <(ytt --ignore-unknown-comments -f ./app-operator) -y

# uninstall
kapp delete -a package-supply-chain-app-operator -y
```

### Developer

The workload.

```sh
# install
kapp deploy -a package-supply-chain-developer -f <(ytt --ignore-unknown-comments -f ./developer) -y

# uninstall
kapp delete -a package-supply-chain-developer -y
```

### Delivery

The delivery supply chain. Still WIP, may not work at all.

```sh
# install
kapp deploy -a package-supply-chain-delivery -f <(ytt --ignore-unknown-comments -f ./delivery) -y

# uninstall
kapp delete -a package-supply-chain-delivery -y
```

### Delivery Developer

The deliverable. Still WIP, may not work at all.

```sh
# install
kapp deploy -a package-supply-chain-delivery-developer -f <(ytt --ignore-unknown-comments -f ./delivery-developer) -y

# uninstall
kapp delete -a package-supply-chain-delivery-developer -y
```

## Update the Dockerfile.carvel image

```sh
docker build . -t us.gcr.io/daisy-284300/nwebb/alm/carvel -f Dockerfile.carvel
docker push us.gcr.io/daisy-284300/nwebb/alm/carvel
```

## Misc

```sh
cd /Users/nwebb/workspace/app-last-mile/cartographer-gitops && git pull && rm -rf config && rm -rf packages && git add . && git commit -m "Clean slate" && git push && cd -
```

## TODOs

- Replace `values.yaml` with values schemas, add `values.yaml` to `.gitignore` (protect credentials)
- Implement delivery chain
- Include sha on imgpkg bundle for package
- Figure out how to properly version `package.yaml`
  - Current solution can give an error if there are leading zeros in any of the fields