# Cartographer

## Prerequisites

You must have `kubectl`, `kapp`, `flux`, `docker` CLIs installed. Then run:

```sh
make install-prereqs
```

## Installation

### App Operator

The supply chain, templates, etc.

```sh
make install-supply-chain
```

### Developer

The workload.

```sh
make install-workload
```

### Delivery

The delivery supply chain. Still WIP, may not work at all.

```sh
make install-cluster-delivery
```

### Delivery Developer

The deliverable. Still WIP, may not work at all.

```sh
make install-deliverable
```

## Uninstall

```sh
# uninstalls everything (except prerequisites)
make uninstall

make uninstall-supply-chain
make uninstall-workload
make uninstall-cluster-delivery
make uninstall-deliverable
```

## Update the Dockerfile.carvel image

```sh
make carvel-image
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