SHELL := /bin/bash

#### Prerequisites ####

.PHONY: install-prereqs
install-prereqs:
	kapp deploy -a cert-manager -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml -y
	kubectl create namespace cartographer-system || true
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

.PHONY: uninstall-prereqs
uninstall-prereqs:
	kapp delete -a kc -y
	flux uninstall --namespace=flux-system
	kapp delete -a tekton -y
	kapp delete -a kpack -y
	kapp delete -a cartographer -y
	k delete ns/cartographer
	kapp delete -a cert-manager -y

#### Supply Chain ####

.PHONY: install-supply-chain
install-supply-chain:
	kapp deploy -a package-supply-chain-app-operator -f <(ytt --ignore-unknown-comments -f ./app-operator -f ../values/app-operator) -y

.PHONY: uninstall-supply-chain
uninstall-supply-chain: uninstall-workload
	kapp delete -a package-supply-chain-app-operator -y

.PHONY: install-workload
install-workload: install-supply-chain
	kapp deploy -a package-supply-chain-developer -f <(ytt --ignore-unknown-comments -f ./developer -f ../values/developer) -y

.PHONY: uninstall-workload
uninstall-workload:
	kapp delete -a package-supply-chain-developer -y

#### Delivery ####

.PHONY: install-cluster-delivery
install-cluster-delivery:
	kapp deploy -a package-supply-chain-delivery -f <(ytt --ignore-unknown-comments -f ./delivery -f ../values/delivery) -y

.PHONY: uninstall-cluster-delivery
uninstall-cluster-delivery:
	kapp delete -a package-supply-chain-delivery -y

.PHONY: install-deliverable
install-deliverable: install-cluster-delivery
	kapp deploy -a package-supply-chain-delivery-developer -f <(ytt --ignore-unknown-comments -f ./delivery-developer -f ../values/delivery-developer) -y

.PHONY: uninstall-deliverable
uninstall-deliverable:
	kapp delete -a package-supply-chain-delivery-developer -y

#### Aggregate ####

.PHONY: uninstall
uninstall: uninstall-deliverable uninstall-cluster-delivery uninstall-workload uninstall-supply-chain

#### Docker Images ####

.PHONY: carvel-image
carvel-image:
	docker build . -t us.gcr.io/daisy-284300/nwebb/alm/carvel -f Dockerfile.carvel
	docker push us.gcr.io/daisy-284300/nwebb/alm/carvel