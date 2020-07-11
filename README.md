# A Tutorial on Microservices, Observability and Chaos on Digital Ocean 

![image](https://user-images.githubusercontent.com/18049790/43352583-0b37edda-9269-11e8-9695-1e8de81acb76.png)

## Disclaimer
* Opinions expressed here are solely my own and do not express the views or opinions of JPMorgan Chase.
* Any third-party trademarks are the intellectual property of their respective owners and any mention herein is for referential purposes only. 

## Table of Contents

1. Introduction
* 1.1 Agenda
* 1.2 Requirements
* 1.3 Cost Warning
2. Digital Ocean (Cloud Provider)
* 2.1 What is Digital Ocean?
* 2.2 Setup Digital Ocean Project 
* 2.3 SSH Setup
* 2.4 Deploy Digital Ocean Droplet (Ubuntu Virtual Machine)
* 2.5 Accessing Digital Ocean Droplet
* 2.6 Deploy Digital Ocean Kubernetes cluster
* 2.7 Loki - Distributed Logging
* 2.8 Accessing the Digital Ocean Kubernetes cluster
    * 2.8.1 doctl (Digital Ocean Command Line Interface)
    * 2.8.2 kubectl (Kubernetes Command Line Interface)
    * 2.8.3 Kubernetes Tools (Optional)
    * 2.8.4 Install Contour Ingress
3. Online Boutique (Micro-service)
* 3.1 What is Online Boutique?
* 3.2 Install Online Boutique
4. Grafana (Metrics UI)
* 4.1 What is Grafana?
* 4.2 Access the Grafana UI
* 4.3 Observing Online Boutique with Grafana
5. Locust (Performance Tool)
* 5.1 What is Locust?
* 5.2 Install Python
* 5.3 Install Locust
* 5.4 Configure Locust
6. Helm (Package Manager)
* 6.1 What is Helm?
* 6.2 Install Helm 3
7. Gremlin (Chaos)
* 7.1 What is Gremlin?
* 7.2 Install Gremlin 
* 7.3 Configure Gremlin
* 7.3 Verify Gremlin Operation
8. Practical - The Fun Starts Here
* 8.1 Start User Interfaces
*   8.1.1 Locust
*   8.1.2 Grafana
*   8.1.3 Gremlin
* 8.2 High CPU Attack
* 8.3 Wrap Up
9. Tutorial Clean Up
* 9.1 CLI Method
* 9.2 GUI Method
*   9.2.1 Kubernetes Cluster
*   9.2.2 Load Balancer
*   9.2.3 Droplet
10. Theory
* 10.1 Documentation
* 10.2 Buzz Words

## 1. Introduction

### 1.1 Agenda
* Deploy a Ubuntu jump host on Digital Ocean with SSH access
* Deploy a Kubernetes cluster on Digital Ocean with Observability software pre-configured
* Install command line tools and utilities
* Deploy Loki for distributed logging on the cluster
* Deploy the Online Boutique micro-services application onto the Kubernetes cluster on Digital Ocean
* Verify operation of the Online Boutique micro-service application
* Observe the Online Boutique micro-service with the Observability software
* Install Load Testing with Locust against the Online Boutique micro-service application
* Perform Chaos Engineering on the Online Boutique micro-service application

### 1.2 Requirements
* 1.2.1 A Digital Ocean Account
  * A credit card or debit card is required to sign up to Digital Ocean
  * The [referral link](https://m.do.co/c/ac62c560d54a) provided gives $100 credit for 60 days to offset the cost of this tutorial 
* 1.2.2 A Terminal Emulator to interact with the cluster
  * If using Windows 10 please install the following software:
    * [PuTTY](https://www.putty.org/) 
    * [PuTTYgen](https://www.puttygen.com/)
    * [WinSCP](https://winscp.net/eng/download.php)
  * Mac  
    * [Terminal on Mac](https://support.apple.com/en-sg/guide/terminal/welcome/mac)

### 1.3 Cost Warning
Note: This stack requires a minimum configuration of
* 3 * Kubernetes Nodes at $10/month (2GB memory / 1 vCPU) 
* 2 * Network Load Balancers at $10/month 
* 1 * Ubuntu Droplet at $5/month
* **Total cost of $55 per month if kept running**

```diff
- Please tear all infrastructure at the end of this tutorial or you will incur a cost at the end of the month -
- I accept no liability for any costs incurred - 
```

## 2. Digital Ocean - Cloud Provider

### 2.1 What is Digital Ocean
* Digital Ocean is a cloud computing vendor that offers Infrastructure as a Service (IaaS) and Container as a Service (CaaS) platforms for software developers.  

### 2.2 Setup a Digital Ocean Project
* 2.2.1 Go to [Digital Ocean](https://www.digitalocean.com) and sign up or login
  * 2.2.1.1 Use this [referral link](https://m.do.co/c/ac62c560d54a) to get $100 for 60 days in credit 
* 2.2.2 Create a new Project called : `digital-ocean-project`
* 2.2.3 Make sure you select the Project called `digital-ocean-project` and proceed to next step

### 2.3 Setup SSH
* 2.3.1 Follow this guide to create and upload SSH keys required to access the Digital Ocean droplet
  * [How-to Add SSH Keys to New or Existing Droplets](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/)
* 2.3.2 Upload the public key to Digital Ocean as `digital-ocean-public-key`

### 2.4 Setup Digital Ocean Droplet
* 2.4.1 Go to "Manage"..."Droplets" on the left tab
* 2.4.2 Select `Create Droplet`
* 2.4.3 Choose an image...Distributions...`Ubuntu`
* 2.4.4 Choose a plan
  * Scroll to the left and select
    * `Standard`...`$5/mo`...`1GB / 1CPU`...`25GB SSD disk`...`1000GB transfer`
* 2.4.5 Choose a datacentre region: `Singapore`
  * Or the closest datacentre region to your physical location
* 2.4.6 VPC Network
  * Dropdown and select `default-sgp1`  
* 2.4.7 Authentication...`SSH Key` should already be selected
* 2.4.8 Choose a hostname: `digital-ocean-droplet`
* 2.4.9 Select Project is set to `Digital Ocean Project`
* 2.4.10 Go to bottom of page and select "Create Droplet"
  * Droplet build usually takes four minutes

### 2.5 Accessing Digital Ocean Droplet
* 2.5.1 In the `digital-ocean-project` page under "Manage".."Droplets" locate the Droplet called `digital-ocean-droplet`
* 2.5.2 Copy the IP address of the `digital-ocean-droplet` by hovering on the IP Address of `digital-ocean-droplet` a `copy` pop-up will appear
* 2.5.3 On Windows
  * Paste the IP address into Putty Host Box
  * Add your Private Key Category...Connection...SSH...Auth
    * `Private Key for Authentication`
* 2.5.4 On Mac open a terminal 
  * `ssh root@<IP Address>` 

* Update and Upgrade Ubuntu and install Python PIP
* `sudo apt-get update`
* `sudo apt-get upgrade -y`
* `sudo apt install -y python3-pip -y`
* `reboot`

### 2.6 Digital Ocean Kubernetes cluster
* 2.6.1 Go to "Discover"..."Marketplace" on the left tab.
* 2.6.2 To the right of "Marketplace Applications" use dropdown to search for "Monitoring".
* 2.6.3 Click the "[Prometheus Kubernetes Version 0.34.0](https://cloud.digitalocean.com/marketplace/5dd48071316b030ef2788c9b?i=9ca3ac)"
* 2.6.4 Select `Install App` by moving mouse over the tile.
* 2.6.5 Leave the Kubernetes version at the latest.
* 2.6.6 Choose a datacentre region: `Singapore`
  * Or the closest datacentre region to your physical location
* 2.6.7 VPC Network should already be: `default-sgp1`  
* 2.6.8 Choose a name: 
  * Enter Cluster name: `digital-ocean-cluster`
* 2.6.9 Select "Create Cluster"
  * Cluster build usually takes four minutes
  * Ignore the "Getting Started Page"
  * Watch the blue completion line and spinning cluster icon
  * When the the blue line runs to the end of the page move on to the next step
  * Click on "Manage".."Kubernetes"
  * At the top of the page the cluster name `digital-ocean-cluster` will have a green icon indicating it is ready for use.

```diff
- **** Wait for the cluster to be ready before continuing, check for green icon on cluster name **** -
```

### 2.7 Install Distributed Logging (Loki)
* 2.7.1 Go to "Discover"..."Marketplace" on the left tab
* 2.7.2 To the right of "Marketplace Applications" use dropdown to search for "Logging"
* 2.7.3 Hover your mouse over the "[Grafana Loki](https://cloud.digitalocean.com/marketplace/5db68268316b031f2a877a63?i=9ca3ac)" tile
* 2.7.4 `Install App`...`Select a cluster option`...`digital-ocean-cluster`
* 2.7.5 Select `Install` button below.
* 2.7.6 Select `Install 1-Click Apps`...Wait until Loki shows as installed

### 2.8 Accessing the Digital Ocean Kubernetes cluster 

The Digital Ocean Kubernetes cluster will be managed from `digital-ocean-droplet` Ubuntu jump host. 

Two binaries need to be installed on `digital-ocean-droplet` to interact with the cluster:
* `doctl` - CLI to interact with Digital Ocean
* `kubectl` - CLI to interact with Kubernetes 

#### 2.8.1 doctl - Digital Ocean Command Line Interface

* doctl Installation
```
cd ~/ && rm -R ~/doctl
cd ~/ && mkdir doctl && cd doctl
curl -LO https://github.com/digitalocean/doctl/releases/download/v1.45.1/doctl-1.45.1-linux-amd64.tar.gz 
tar -xvf doctl-1.45.1-linux-amd64.tar.gz
sudo mv ~/doctl/doctl /usr/local/bin
```

* doctl Configuration
  * Login to Digital Ocean
  * Go to "Account".."API" on the left tab.
  * Applications & API..Tokens/Keys..Personal access tokens
  * Select `Generate New Token`
  * Token name: `digital-ocean-access-token`
    * Generate Token
  * Copy the generated token value for the next step.
  * Go to the right of the token, a `copy` prompt will pop up 
  * Run this command and input the `digital-ocean-access-token` value when prompted
    * `doctl auth init`
  * Run this command to the digital-ocean-cluster credentials to kubeconfig
    * `doctl kubernetes cluster kubeconfig save digital-ocean-cluster`

#### Required Kubernetes Tools

Please use this repo [Install Kubernetes Tools](https://github.com/jamesbuckett/kubernetes-tools) to install the following:
* kubectl - Interact with Kubernetes cluster
* kubectx - Change clusters
* kubens - Change namespaces like you would directories
* kube-ps1 - Changes Prompt to reflect current cluster and namespace
* helm 3 - Kubernetes package installer  
* Octant - Kubernetes Web User Interface

#### 2.8.2 kubectl - Kubernetes Command Line Interface

`kubectl` is a command line tool used to interact with the `digital-ocean-cluster` Kubernetes clusters.

In the diagram below you see `kubectl` interacts with the Kubernetes API Server.

![image](https://user-images.githubusercontent.com/18049790/65854426-30332f00-e38f-11e9-89a9-b19cc005db91.png)
Credit to [What is Kubernetes](https://www.learnitguide.net/2018/08/what-is-kubernetes-learn-kubernetes.html)

In your Linux terminal that you will use to interact with the Digital Ocean Kubernetes cluster install `kubectl`.

* [kubectl](https://kubernetes.io/docs/reference/kubectl/overview) is the official Kubernetes command-line tool, which you’ll use to connect to and interact with the cluster.
* The Kubernetes project provides [installation instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl) for kubectl on a variety of platforms. 

Set cluster context and alias
```
cd ~
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo "alias cls='clear'" >> ~/.bashrc
echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kga='kubectl get all'" >> ~/.bashrc
```

And reinitialize your shell with `. ~/.bashrc`

```
k config use-context do-sgp1-digital-ocean-cluster
k version
```

Use 'k version' to make sure that your installation is working and 'kubectl' cli is within one minor version of your cluster.
```
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.3", GitCommit:"2e7996e3e2712684bc73f0dec0200d64eec7fe40", GitTreeState:"clean", BuildDate:"2020-05-20T12:52:00Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.5", GitCommit:"e0fccafd69541e3750d460ba0f9743b90336f24f", GitTreeState:"clean", BuildDate:"2020-04-16T11:35:47Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
```

Use `k cluster-info` to get cluster related information
```
[root@digital-ocean-droplet ~/kubectl (do-sgp1-digital-ocean-cluster:default)]# k cluster-info
Kubernetes master is running at https://e8d7b634-effb-4d9e-8995-4607e38ff95d.k8s.ondigitalocean.com
CoreDNS is running at https://e8d7b634-effb-4d9e-8995-4607e38ff95d.k8s.ondigitalocean.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

#### 2.8.4 Install Contour Ingress

What is [Countour](https://github.com/projectcontour/contour)?
* An Ingress is an API object that manages external access to the services in a cluster, typically HTTP.
* Ingress may provide load balancing, SSL termination and name-based virtual hosting
* Contour is an Ingress controller for Kubernetes that works by deploying the Envoy proxy as a reverse proxy and load balancer. 
* Contour supports dynamic configuration updates out of the box while maintaining a lightweight profile.

Create a namespace for Contour: `kubectl create namespace ns-contour`

```
helm upgrade --install contour-release stable/contour --namespace ns-contour --set service.loadBalancerType=LoadBalancer
```

Run this command : `watch -n 1 kubectl get all -n ns-contour`

Watch the output until this line changes 
* from : `service/contour-release   LoadBalancer   x.x.x.x   <pending>     80:31362/TCP,443:30878/TCP   40s`
* to   : `service/contour-release   LoadBalancer   x.x.x.x   x.x.x.x     80:31362/TCP,443:30878/TCP   40s`

Where `x.x.x.x` is a valid EXTERNAL-IP which is the IP address to access your Contour Ingress.

The Load Balancer takes about four minutes to provision.

## 3. Online Boutique - Micro-service Sample Application

### 3.0 Acknowledgement of Source
* Acknowledgement and credit to all the [contributors](https://github.com/GoogleCloudPlatform/microservices-demo/graphs/contributors) on the [microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo) project.

### 3.1 What is [Online Boutique?](https://github.com/GoogleCloudPlatform/microservices-demo/) 
* This project provides a realistic micro-services oriented e-commerce application. 
* Online Boutique is a cloud-native microservices demo application. 
* Online Boutique consists of a 10-tier microservices application. 
* The application is a web-based e-commerce app where users can browse items, add them to the cart, and purchase them.
* Online Boutique is composed of many microservices written in different languages that talk to each other over gRPC.

![image](https://user-images.githubusercontent.com/18049790/83969793-85ebae00-a904-11ea-9802-64155b8ea5c7.png)

### 3.2 Install the Online Boutique Application 
* Create a namespace for Online Boutique.
* `k create namespace ns-microservices-demo`
* `k apply -n ns-microservices-demo -f "https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/complete-demo.yaml"`

Run this command : `watch -n 1 kubectl get all -n ns-microservices-demo`

```
Every 1.0s: kubectl get all -n ns-microservices-demo                             digital-ocean-droplet: Mon Jun 29 04:20:40 2020

NAME                                         READY   STATUS              RESTARTS   AGE
pod/adservice-5c9c7c997f-czcrh               0/1     Pending             0          14s
pod/cartservice-6d99678dd6-vcn7c             0/1     Running             0          16s
pod/checkoutservice-779cb9bfdf-mw6rl         0/1     Running             0          18s
pod/currencyservice-5db6c7d559-99mxk         0/1     ContainerCreating   0          15s
pod/emailservice-5c47dc87bf-xrqpk            0/1     ContainerCreating   0          18s
pod/frontend-5fcb8cdcdc-dlhqk                0/1     Running             0          17s
pod/paymentservice-6564cb7fb9-qxsrn          0/1     ContainerCreating   0          16s
pod/productcatalogservice-5db9444549-hgsmj   0/1     Running             0          16s
pod/recommendationservice-ff6878cf5-c9xtm    0/1     ContainerCreating   0          17s
pod/redis-cart-57bd646894-tbnrg              0/1     Running             0          15s
pod/shippingservice-f47755f97-677m6          1/1     Running             0          15s

NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/adservice               ClusterIP      10.245.77.165    <none>        9555/TCP       14s
service/cartservice             ClusterIP      10.245.172.236   <none>        7070/TCP       16s
service/checkoutservice         ClusterIP      10.245.91.142    <none>        5050/TCP       17s
service/currencyservice         ClusterIP      10.245.178.247   <none>        7000/TCP       15s
service/emailservice            ClusterIP      10.245.94.149    <none>        5000/TCP       18s
service/frontend                ClusterIP      10.245.9.152     <none>        80/TCP         17s
service/paymentservice          ClusterIP      10.245.241.49    <none>        50051/TCP      16s
service/productcatalogservice   ClusterIP      10.245.61.176    <none>        3550/TCP       16s
service/recommendationservice   ClusterIP      10.245.71.224    <none>        8080/TCP       17s
service/redis-cart              ClusterIP      10.245.7.209     <none>        6379/TCP       15s
service/shippingservice         ClusterIP      10.245.96.86     <none>        50051/TCP      15s

NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/adservice               0/1     1            0           14s
deployment.apps/cartservice             0/1     1            0           16s
deployment.apps/checkoutservice         0/1     1            0           18s
deployment.apps/currencyservice         0/1     1            0           15s
deployment.apps/emailservice            0/1     1            0           18s
deployment.apps/frontend                0/1     1            0           17s
deployment.apps/paymentservice          0/1     1            0           17s
deployment.apps/productcatalogservice   0/1     1            0           16s
deployment.apps/recommendationservice   0/1     1            0           17s
deployment.apps/redis-cart              0/1     1            0           15s
```

To Access Online Boutique 
* Obtain the external IP address of Online Boutique.
* `kubectl -n ns-contour  get service contour-release | awk 'FNR == 2 {print $4}`
* This is the EXTERNAL-IP of the Online Boutique
* Paste the EXTERNAL-IP into your web browser.
* You should see a e-commerce website called Online Boutique
* Feel free to browse around and order some hipster products

## 4. Grafana - UI

![image](https://user-images.githubusercontent.com/18049790/65003256-3c2ae580-d8e7-11e9-992d-30358d52e731.png)

### 4.1 What is Grafana?
* Grafana is an open source metric analytics & visualization suite
* It is most commonly used for visualizing time series data for infrastructure and application analytics
* We will use it to observe the Online Boutique micro-service

### 4.2 Access the Grafana UI
```diff
- **** This part is broken the installer does not create the external Load Balancer **** -
- **** Follow the steps below **** -
```

Use kubectl to change the Service Type from ClusterIP to LoadBalancer
```
cd ~/ && mkdir fix-grafana && cd fix-grafana
```
Export the prometheus-operator-grafana service definition
```
kubectl get service prometheus-operator-grafana -o yaml --export -n prometheus-operator > prometheus-operator-grafana.yml
```
Update the prometheus-operator-grafana service definition with LoadBalancer
```
sed -i 's/ClusterIP/LoadBalancer/g' prometheus-operator-grafana.yml
```
Apply the file
```
kubectl apply -f prometheus-operator-grafana.yml -n prometheus-operator
```

* Grafana is exposed via a DigitalOcean Load Balancer.
* Get the IP address to access your Grafana instance by running the following in a terminal shell and copying the EXTERNAL-IP and pasting it into a browser.

`kubectl -n prometheus-operator get svc prometheus-operator-grafana | awk 'FNR == 2 {print $4}'`

```
root@digital-ocean-droplet:~# k -n prometheus-operator get svc prometheus-operator-grafana
NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
prometheus-operator-grafana   LoadBalancer   10.245.220.96   x.x.x.x          80:30459/TCP   9m4s
```

* Paste the EXTERNAL-IP into your web browser.
* The default username and password are `admin` and `prom-operator` 
* Once you have logged in the default Grafana Home dashboard will be displayed. 
* To see cluster specific graphs enabled in this stack go to the “Home” menu in the upper left hand corner of your Grafana web browser page. 

Add Loki as a DataSource
* Go to left panel...`Configuration`...`Data Sources`...`Add data Source`...`Loki`...`Select`
* URL : `http://loki.loki:3100`...`Save and Test`

Install Loki Dashboard
* On left side select `Create` icon...`Import`...`Grafana.com Dashboard`
* `12019`...`Import`
* Select `Loki` as Loki Data Source
* Select `Prometheus` as Prometheus Data Source
* On left side select `Dashboard` icon...`Manage`...`Find`...`loki`
* Open the `Loki Dashboard quick search` dashboard and look around

### 4.3 Observing Online Boutique with Grafana

Top left click on `Home`

Under `General` select `Kubernetes / Compute Resources / Namespace(Pods)`
* datasource: Prometheus
* Namespace: `ns-microservices-demo`
* Top Right click Clock Icon with text `Last 1 hour`
  * Under Quick Ranges
    * Select `Last 5 minutes`
* Top Right click last icon that looks like Recycle Icon
  * In drop down select `5s`

Scroll down the page and observe the metrics for the Online Boutique micro-service
* CPU Usage
* CPU Quota
* Memory Usage
* Memory Quota
* Network

## 5. Locust - Load Testing

### 5.1 What is [Locust?](https://locust.io/)
* Locust is an easy-to-use, distributed, user load testing tool. 
* It is intended for load-testing web sites (or other systems) and figuring out how many concurrent users a system can handle. 

### 5.2 Install Locust

```
pip3 install locust
```

### 5.3 Configure Locust

```
cd ~/ && rm -R ~/locust
cd ~/ && mkdir locust && cd locust
wget https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/locustfile.py
```

Obtain the external IP address of Online Boutique.
* `kubectl -n ns-contour  get service contour-release | awk 'FNR == 2 {print $4}`
* This is the EXTERNAL-IP of the Online Boutique.
* Use that address to stress test the micro-services application.

Export the front end of Online Boutique
`export FRONTEND_ADDR=<EXTERNAL-IP>`

Start locust with this command: `locust --host="http://${FRONTEND_ADDR}" -u "${USERS:-10}" &`

Obtain the external IP address of `digital-ocean-droplet`
* `doctl compute droplet list | awk 'FNR == 2 {print $3}'`
* This is the `Public IPv4` for `digital-ocean-droplet`

Browse to : `http://<Public IPv4>:8089/`
* Enter these values 
  * Number of Users to Simulate: 500
  * Hatch Rate: 10
  * Click `Start Swarming`

On main panel select `Charts`
* Top Right note Failures are 0%
* Keep the browser window open.

## 6. Helm - Package Manager 

Skip this step if you install Helm earlier.

### 6.1 What is Helm?
* Helm is an application package manager running atop Kubernetes. 
* It allows describing the application structure through helm-charts and managing those charts it with simple commands

### 6.2 Install Helm 3
```
cd ~/ && mkdir helm-3 && cd helm-3
wget https://get.helm.sh/helm-v3.2.1-linux-amd64.tar.gz
tar -zxvf helm-v3.2.1-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```

## 7. Gremlin - Chaos

### 7.1 What is Gremlin?
* Software as a Service Choas Engineering Platform 
* Chaos Engineering is the discipline of experimenting on a distributed system in order to build confidence in the system’s capability to withstand turbulent conditions in production.

### 7.2 Install Gremlin

Create a gremlin directory
```
cd ~/ && rm -R ~/gremlin
cd && mkdir gremlin && cd gremlin
```

Signup for Gremlin service
* Go to this [link](https://app.gremlin.com/signup)
* Sign Up for an account
* Login to the Gremlin App using your Company name and sign-on credentials. 
* These were emailed to you when you signed up to start using Gremlin.
* Top Right click on `Company Settings`
* Click `Teams` tab
* CLick on your User
* Click on Configuration
* Click the blue Download button to save your certificates to your local computer. 
  * If on Windows download the `certificate.zip` file to c:\Users\<your-name>\Downloads
  * If on Mac download the `certificate.zip` to the `~/download` directory.
* The downloaded `certificate.zip` contains both a public-key certificate and a matching private key.
* Obtain the external IP address of `digital-ocean-droplet`
  * `doctl compute droplet list | awk 'FNR == 2 {print $3}'`
  * This is the `Public IPv4` for `digital-ocean-droplet`
* For Windows use WinSCP to upload `certificate.zip` to `digital-ocean-droplet` to `home/root/gremlin`
  * Add your private key to WinSCP 
    * Advanced..SSH..Authentication..Private key file
* For Mac use `scp` to upload `certificate.zip` to `digital-ocean-droplet`
  * `scp certificate.zip root@<Public IPv4>:/root/gremlin/`

* Unzip the `certificate.zip` and rename your certificate and key files to `gremlin.cert` and `gremlin.key`
```
cd ~/gremlin
sudo apt-get install unzip
unzip certificate.zip
mv *.priv_key.pem gremlin.key
mv *.pub_cert.pem gremlin.cert
```
Create a namespace and secret for Gremlin
```
k create ns ns-gremlin
k create secret generic gremlin-team-cert --from-file=./gremlin.cert --from-file=./gremlin.key -n ns-gremlin
```

### 7.3 Configure Gremlin

Let Gremlin know your Gremlin team ID and your Kubernetes cluster name
```
export GREMLIN_TEAM_ID="changeit"
export GREMLIN_CLUSTER_ID=digital-ocean-cluster
```

* Replace `"changeit"` with the value from the [Gremlin page](https://app.gremlin.com/signup) 
  * Obtain `GREMLIN_TEAM_ID` here: 
    * Top Right click on `Company Settings`
    * Click `Manage Teams` tab
    * Click on your User
    * Click on Configuration
    * Your `Team ID` should be on the top row
    * Your `Team ID` is your `GREMLIN_TEAM_ID`

If you have trouble with this section please go [here](https://www.gremlin.com/community/tutorials/how-to-install-and-use-gremlin-with-kubernetes/)

Add the Gremlin helm chart
```
helm repo remove gremlin
helm repo add gremlin https://helm.gremlin.com
```

Install the Gremlin Kubernetes client
```
helm install gremlin gremlin/gremlin \
  --namespace ns-gremlin \
  --set gremlin.teamID=$GREMLIN_TEAM_ID \
  --set gremlin.clusterID=$GREMLIN_CLUSTER_ID
```

### 7.4 Verify Gremlin Operation

`watch -n 1 kubectl get all -n ns-gremlin`

You should see similar output to the following.
```
Every 1.0s: kubectl get all -n gremlin                                           digital-ocean-droplet: Sun Jun  7 12:08:54 2020

NAME                        READY   STATUS              RESTARTS   AGE
pod/chao-69b5cbc94c-5cqgc   0/1     ContainerCreating   0          37s
pod/gremlin-jjh5c           0/1     ContainerCreating   0          37s
pod/gremlin-l6tbl           0/1     ContainerCreating   0          37s
pod/gremlin-w7nqh           0/1     ContainerCreating   0          37s

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/gremlin   3         3         0       3            0           <none>          37s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/chao   0/1     1            0           37s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/chao-69b5cbc94c   1         1         0       37s
```

## 8. Practical - High CPU Resource Attack

### 8.1 Start the User Interfaces

#### 8.1.1 Locust 
* Locust should still be running from a previous step.
  * `doctl compute droplet list | awk 'FNR == 2 {print $3}'`
  * This is the `Public IPv4` for `digital-ocean-droplet`
  * Browse to : `http://<Public IPv4>:8089/`

#### 8.1.2 Grafana 
* Grafana should still be running from a previous step.
  * `k -n prometheus-operator get svc prometheus-operator-grafana`
  * Put `EXTERNAL-IP` into a browser.

#### 8.1.3 Gremlin
* Login to [Gremlin](https://app.gremlin.com/signup)

### 8.2 High CPU Attack
* Switch to the Locust UI 
  * Check the Locust UI switch to the charts view if required.
  * Reload the page if required

![locust-1](https://user-images.githubusercontent.com/18049790/66459128-f8229f00-eaa6-11e9-9fdb-f5cf07e591e4.png)

* Switch to the Grafana UI 
  * Top left click on `Home`
  * Under General
    * `Nodes`
      * USE is an acronym for Utilization, Saturation, and Errors (resource-scoped)
      * RED is an acronym for Rate, Errors, and Duration (request-scoped)
  * Top Right click Clock Icon with text Last 1 hour
    * Select Last 5 minutes
  * Top Right click last icon that looks like Recycle Icon
    * In drop down select 5s
  
![grafana-1](https://user-images.githubusercontent.com/18049790/66459139-fd7fe980-eaa6-11e9-9ff4-6eac75f92742.png)  
  
* Switch to the Gremlin UI
  * Left side select `Attacks`
  * Select `Infrastructure`
  * Select `New Attack`
  * Choose Hosts to target
    * Target all hosts
      * Select check boxes next to all hosts that start with `pool`
      * Interface will indicated `4 of 4 HOSTS TARGETED`
  * Scroll down select `Choose a Gremlin`
  * Under `Category` select `Resource` and `CPU`
    * Next to `Length` enter `180`
    * Next to `CPU Capacity` enter `100`
  * Scroll to bottom of page select `Unleash Gremlin`
  
* Switch to the Grafana UI
  * Observe the CPU Utilization reaching 100% utilization 
   
  ![grafana-2](https://user-images.githubusercontent.com/18049790/66459191-20aa9900-eaa7-11e9-875a-f64b9c9ff163.png)
  
* Switch to the Locust UI
  * Observe top right that `Failures` are 0%

![locust-2](https://user-images.githubusercontent.com/18049790/66459196-2607e380-eaa7-11e9-8ec4-e7401441697b.png)

You have successfully performed a CPU Resource Attack against the infrastrucure nodes.

What you are observing is the following:
* Gremlin is causing the Kubernetes Worker Nodes to go to 100% CPU utilization
* Kubernetes is ensuring the the Online Boutique micro-service is high resilient and available 
* Locust is hitting the Online Boutique front-end container and reporting `0%` failures.

Optional Rerun
* On the Gremlin UI click the attack
* Top right click `Rerun`
* Scroll to bottom of page and select `Unleash Gremlin`
* Switch to the Grafana UI 
  * Under General
    * `USE Method / Cluster`
      * USE is an acronym for Utilization, Saturation, and Errors (resource-scoped)
      * RED is an acronym for Rate, Errors, and Duration (request-scoped)
  * Top Right click Clock Icon with text Last 1 hour
    * Select Last 5 minutes
  * Top Right click last icon that looks like Recycle Icon
    * In drop down select 5s
* This is the aggregate view of the Kubernetes cluster resources.
 
## 8.3 Wrap Up
* You deployed a Kubernetes Cluster on Digital Ocean with Prometheus and Grafana pre-installed and configured.
* You deployed a micro-services application called Online Boutique to run on the Cluster.
* You observed metrics from the micro-services application with Prometheus and Grafana.
* You deployed a performance tool called Locust to stress test the micro-services application and observe any failures.
* You installed Gremlin to perform a Chaos Experiment (CPU Resource Attack) on the micro-services application.

## 9. Tutorial Clean Up 

Two methods to clean up
* GUI 
* CLI

### 9.1 CLI Method

Delete Kubernetes Cluster
* `doctl kubernetes cluster delete digital-ocean-cluster -f`

Delete Kubernetes Cluster
* `doctl compute load-balancer list | awk 'FNR == 2 {print $1}'`
  * Get ID for each Load Balancer
* `doctl compute load-balancer delete <ID> -f`
  * Confirm with `y`
  
Delete Droplet  
* `doctl compute droplet delete digital-ocean-droplet -f`  

### 9.2 GUI Method

Login to Digital Ocean

### 9.2.1 Kubernetes 
* Left side bar select Kubernetes
* Select your cluster 
* Top right select `Actions` button
* Select `Destroy`
* On next page confirm by selecting `Destroy` again
* Enter `digital-ocean-cluster` to enable deletion

### 9.2.2 Load Balancer
* Left side bar select Networking
* Select Load Balancers
* Select the top Load Balancer
* Select Settings
* Scroll to bottom and select Destroy
* Select the Confirm button 
* Repeat for all Load Balancers

### 9.2.3 Droplet
* Left side bar select "Manage".."Droplets"
* On right side of `digital-ocean-droplet` select `More` button
* Select `Destroy`
* Select `Destroy` again

## 10. Theory 

### 10.1 Documentation 
* [Kubernetes](https://kubernetes.io)
* [Prometheus](https://prometheus.io)
* [Grafana](https://grafana.com)
* [Prometheus NodeExporter](https://github.com/prometheus/node_exporter/blob/master/README.md)
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/blob/master/README.md)
* [metrics-server](https://github.com/kubernetes-incubator/metrics-server/blob/master/README.md)
* [Gremlin](https://www.gremlin.com/)
* [Locust](https://locust.io/)

### 10.2 Buzz Words
* Digital Ocean - Developer focused Cloud Provider.
* Micro-service - Collection of **loosely coupled services** that are **independently deployable and scalable**.
* Kubernetes - Open-source self-healing platform to deploy, scale and operate containers.
* Prometheus - Prometheus is an open source toolkit to monitor and alert.
* Grafana - Grafana offers data visualization & Monitoring with support for Graphite, InfluxDB, Prometheus.
* Kube State Metrics - A simple service that listens to the Kubernetes API server and generates metrics about the state of the objects. 
* Prometheus NodeExporter - UNIX/Linux hardware and Operating System metrics.
* Kubernetes Metrics Server - Kubernetes resource usage metrics, such as container CPU and memory usage, are available in Kubernetes through the Metrics API.
* Gremlin - A Software as a Service Chaos Engineering platform..
* Locust - A performance testing tool 

*End of Section*
