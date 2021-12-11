# Pinniped

Web application to create, seal, upload, and commit secrets into source control for you. Ideal for GitOps

# Usage

Currently, Pinniped uses your kubeconfig file in `$HOME/.kube/config`. From this it uses the current context to authenticate to your kubernetes cluster

# Getting Started

```
bundle install
rails server
```