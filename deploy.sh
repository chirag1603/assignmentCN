#!/bin/bash
set -x -v
echo '----------Initializing terraform---------'
terraform init
echo '----------Applying Modules---------------'
terraform apply -auto-approve
sleep 60
echo '----------Setting the Kubeconfig on local----------'
aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)
echo '----------Status of Worker Nodes & Cluster Health-------------------'
kubectl cluster-info
kubectl get nodes
echo '----------Deploying the node application------------'
helm install demo-app app/helm-node/helloworld-chart/
echo '----------Creating Pods-------------'
sleep 20
kubectl get pods
echo '----------Creating Load Balancer on AWS-------------'
sleep 30
export SERVICE_IP=$(kubectl get svc --namespace default demo-app-helloworld-chart --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo '----------Please hit the below url to access your node application--------'
echo http://$SERVICE_IP:80