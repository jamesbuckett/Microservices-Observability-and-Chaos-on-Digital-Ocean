# A Tutorial on Microservices, Observability and Chaos on Digital Ocean 

![image](https://user-images.githubusercontent.com/18049790/43352583-0b37edda-9269-11e8-9695-1e8de81acb76.png)

## Disclaimer
* Opinions expressed here are solely my own and do not express the views or opinions of JPMorgan Chase.
* Any third-party trademarks are the intellectual property of their respective owners and any mention herein is for referential purposes only. 

## Table of Contents
* Introduction
  * Agenda
  * Requirements
  * Cost Warning
* Digital Ocean (Cloud Provider)
  * Setup Digital Ocean Project 
  * SSH Setup
  * Deploy Digital Ocean Droplet (Ubuntu Virtual Machine)
  * Deploy Digital Ocean Kubernetes cluster
  * Accessing the Digital Ocean Kubernetes cluster
    * doctl (Digital Ocean Command Line Interface)
    * kubectl (Kubernetes Command Line Interface)
* Socks Shop (Micro-service)
  * What is Socks Shop?
  * Install Socks Shop
* Grafana (Metrics UI)
  * What is Grafana?
  * Observing Socks Shop with Grafana
* Locust (Performance Tool)
  * What is Locust?
  * Install Python
  * Install Locust
  * Configure Locust
* Helm (Package Manager)
  * What is Helm?
  * Install Helm
  * Configure Helm
* Gremlin (Chaos)
  * What is Gremlin?
  * Install Gremlin
  * Verify Gremlin is working
* Practical - The Fun Starts Here
  * Start User Interfaces
    * Locust
    * Grafana
    * Gremlin
  * High CPU Attack
  * Wrap Up
* Kube Monkey (Chaos) - Optional
* Tutorial Clean Up
  * CLI Method
  * GUI Method
* Theory
  * Prometheus Theory - Time Series Database 
  * metrics-server Theory - Kubernetes Metrics
  * Documentation
  * Buzz Words
* Tools
  * Octant

## Introduction

### Agenda
* Deploy a Ubuntu jump host on Digital Ocean with SSH access
* Deploy a Kubernetes cluster on Digital Ocean with Observability software pre-configured
* Deploy the Socks Shop micro-services application onto the Kubernetes cluster on Digital Ocean
* Verify operation of the Socks Shop micro-service
* Observe the Socks Shop micro-service with the Observability software
* Perform Chaos Engineering on the Socks Shop micro-service

### Requirements
* A Digital Ocean Account
  * A credit card or debit card is required to sign up to Digital Ocean
  * The Referal Link provided gives $50 credit for 30 days to offset the cost of this tutorial 
* A Terminal Emulator to interact with the cluster
  * If using Windows 10 please install the following software:
    * [PuTTY](https://www.putty.org/) 
    * [PuTTYgen](https://www.puttygen.com/)
    * [WinSCP](https://winscp.net/eng/download.php)
  * Mac  
    * [Terminal on Mac](https://support.apple.com/en-sg/guide/terminal/welcome/mac)

### Cost Warning
Note: This stack requires a minimum configuration of
* 3 * Kubernetes Nodes at $10/month (2GB memory / 1 vCPU) 
* 2 * Network Load Balancer at $10/month 
* 1 * Ubuntu Droplet at $5/month
* **Total cost of $55 per month if kept running**

```diff
- Please tear all infrastructure at the end of this tutorial or you will incur a cost at the end of the month -
```

## Digital Ocean - Cloud Provider

### What is Digital Ocean
* Digital Ocean is a cloud computing vendor that offers an Infrastructure as a Service (IaaS) platform for software developers.  

### Setup a Digital Ocean Project
* Go to [Digital Ocean](https://www.digitalocean.com) and sign up or login.
  * Use this [referral link](https://m.do.co/c/ac62c560d54a) to get $50 in credit 
* Create a new Project called : `digital-ocean-project`
* Make sure you select the Project called `digital-ocean-project` and proceed to next step

### Setup SSH
* Follow this guide to create and upload SSH keys required to access the Digital Ocean droplet
  * [How-to Add SSH Keys to New or Existing Droplets](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/)
* Upload the public key to Digital Ocean as `digital-ocean-public-key`

### Setup Digital Ocean Droplet
* Go to "Manage".."Droplets" on the left tab
* Select `Create Droplet`
* Choose an image..Distributions..`Ubuntu`
* Choose a plan
  * Scroll to the top and select
  * Or scroll to left 
    * `Standard`..`Shared CPU`..`1vCPU`..`1GB`..`25GB`..`1TB`..`$5/mo`
* Choose a datacentre region: `Singapore`
  * Or the closest datacentre region to your physical location
* Authentication..`SSH Key` should already be selected
* Choose a hostname: `digital-ocean-droplet`
* Select Project is set to `Digital Ocean Project`
* Go to bottom of page and select "Create Droplet"
  * Droplet build usually takes four minutes

### Accessing Digital Ocean Droplet
* In the `digital-ocean-project` page locate the Droplet called `digital-ocean-droplet`
* Copy the IP address of the `digital-ocean-droplet` by hovering on the IP Address of `digital-ocean-droplet` a `copy` pop-up will appear
* On Windows
  * Paste the IP address into Putty Host Box
  * Add your Private Key Category..Connection..SSH..Auth
    * `Private Key for Authentication`
* On Mac open a terminal 
  * `ssh root@<IP Address>` 
  
### Digital Ocean Kubernetes cluster
* Go to "Discover".."Marketplace" on the left tab.
* Under "Find a Solution" click the "Kubernetes - New" tab.
* Click the "[Kubernetes Monitoring Stack](https://cloud.digitalocean.com/marketplace/5d163fdd29a6ab0d4c7d5274?i=9ca3ac)"
* Select "Create Kubernetes Monitoring Cluster"
* Select a Kubernetes version : `1.15.5-do.2`
* Choose a datacentre region: `Singapore`
  * Or the closest datacentre region to your physical location
* VPC Network: `default-sgp1`  
* Choose a name: 
  * Enter Cluster name: `digital-ocean-cluster`
* Go to bottom of page and select "Create Cluster"
  * Cluster build usually takes four minutes

Go back to the main page to confirm that the cluster and load balancer have been created before proceeding.
* At the top of the page the cluster name `digital-ocean-cluster` will have a green icon indicating it is ready for use.
* Scroll to the top of the page and check for green icon on the digital-ocean-cluster name.

```diff
- **** Wait for the cluster to be ready before continuing, check for green icon on cluster name **** -
```

### Accessing the Digital Ocean Kubernetes cluster 

The Digital Ocean Kubernetes cluster will be managed from `digital-ocean-droplet` Ubuntu jump host. 

Two binaries need to be installed on `digital-ocean-droplet` to interact with the cluster:
* `doctl` - CLI to interact with Digital Ocean
* `kubectl` - CLI to interact with Kubernetes 

#### doctl - Digital Ocean Command Line Interface

* doctl Installation
```
cd ~/ && mkdir doctl && cd doctl
curl -LO https://github.com/digitalocean/doctl/releases/download/v1.36.0/doctl-1.36.0-linux-amd64.tar.gz 
tar -xvf doctl-1.36.0-linux-amd64.tar.gz
sudo mv ~/doctl/doctl /usr/local/bin
```

* doctl Configuration
  * Login to Digital Ocean
  * Go to "Manage".."API" on the left tab.
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

#### kubectl - Kubernetes Command Line Interface

`kubectl` is a command line tool used to interact with the `digital-ocean-cluster` Kubernetes clusters.

In the diagram below you see `kubectl` interacts with the Kubernetes API Server.

![image](https://user-images.githubusercontent.com/18049790/65854426-30332f00-e38f-11e9-89a9-b19cc005db91.png)
Credit to [What is Kubernetes](https://www.learnitguide.net/2018/08/what-is-kubernetes-learn-kubernetes.html)

In your Linux terminal that you will use to interact with the Digital Ocean Kubernetes cluster install `kubectl`.

* [kubectl](https://kubernetes.io/docs/reference/kubectl/overview) is the official Kubernetes command-line tool, which you’ll use to connect to and interact with the cluster.
* The Kubernetes project provides [installation instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl) for kubectl on a variety of platforms. 

Install kubectl
```
cd ~/ && mkdir kubectl && cd kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

Set context and alias
```
kubectl config use-context do-sgp1-digital-ocean-cluster
alias k='kubectl'
k version
```

Use 'k version' to make sure that your installation is working and within one minor version of your cluster.
```
root@digital-ocean-droplet:~/kubectl# kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.0", GitCommit:"e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529", GitTreeState:"clean", BuildDate:"2019-06-19T16:40:16Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.5", GitCommit:"20c265fef0741dd71a66480e35bd69f18351daea", GitTreeState:"clean", BuildDate:"2019-10-15T19:07:57Z", GoVersion:"go1.12.10", Compiler:"gc", Platform:"linux/amd64"}
```

Use `k cluster-info` to get cluster related information
```
Kubernetes master is running at https://b3d48d0d-582a-437f-91cb-75dc6584331f.k8s.ondigitalocean.com
CoreDNS is running at https://b3d48d0d-582a-437f-91cb-75dc6584331f.k8s.ondigitalocean.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://b3d48d0d-582a-437f-91cb-75dc6584331f.k8s.ondigitalocean.com/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
```

## Socks Shop - Micro-service

### What is [Socks Shop?](https://microservices-demo.github.io) 
* This project provides a realistic micro-services oriented e-commerce application. 
* See the diagram below for the diverse languages, frameworks and databases used in the micro-services application.

![image](https://user-images.githubusercontent.com/18049790/65854068-1d6c2a80-e38e-11e9-9337-cc398eb9a1f0.png)
Credit to [Learn Micro-service from Sock Shop](https://medium.com/@panan_songyu/learn-micro-service-from-sock-shop-1-d80e815f3394)

### Install the Socks Shop Application 
* Create a namespace for sock shop.
* `k create namespace sock-shop`
* `k apply -n sock-shop -f "https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/complete-demo.yaml"`

Run this command : `watch -n 1 kubectl get all -n sock-shop`

Watch the output until this line changes 
* from : `service/front-end      LoadBalancer   x.x.x.x      <pending>     80:30001/TCP   2m5s`
* to   : `service/front-end      LoadBalancer   x.x.x.x      x.x.x.x       80:30001/TCP   3m15s`

Where `x.x.x.x` is a valid EXTERNAL-IP which is the IP address to access your Socks Shop micro-service.

```
Every 1.0s: kubectl get all -n sock-shop                                               digital-ocean-droplet: Thu Oct 17 07:34:50 2019

NAME                                READY   STATUS              RESTARTS   AGE
pod/carts-56c6fb966b-8schz          1/1     Running             0          2m7s
pod/carts-db-5678cc578f-zprvg       1/1     Running             0          2m8s
pod/catalogue-644549d46f-6zqbr      1/1     Running             0          2m6s
pod/catalogue-db-6ddc796b66-zj2cc   1/1     Running             0          2m7s
pod/front-end-5594987df6-69wkf      1/1     Running             0          2m5s
pod/front-end-5594987df6-8vs7k      1/1     Running             0          2m5s
pod/front-end-5594987df6-nxzcw      1/1     Running             0          2m5s
pod/front-end-5594987df6-pl8qm      1/1     Running             0          2m5s
pod/orders-749cdc8c9-9dh85          1/1     Running             0          2m4s
pod/orders-db-5cfc68c4cf-sslpx      1/1     Running             0          2m5s
pod/payment-54f55b96b9-kw7dj        1/1     Running             0          2m4s
pod/queue-master-6fff667867-bbv8f   1/1     Running             0          2m3s
pod/rabbitmq-bdfd84d55-njmnj        1/1     Running             0          2m3s
pod/shipping-78794fdb4f-b8s7w       1/1     Running             0          2m2s
pod/user-77cff48476-2bnvh           1/1     Running             0          2m1s
pod/user-db-99685d75b-gvbsp         0/1     ContainerCreating   0          2m2s

NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/carts          ClusterIP      10.245.154.64    <none>        80/TCP         2m7s
service/carts-db       ClusterIP      10.245.73.210    <none>        27017/TCP      2m7s
service/catalogue      ClusterIP      10.245.249.82    <none>        80/TCP         2m6s
service/catalogue-db   ClusterIP      10.245.195.109   <none>        3306/TCP       2m6s
service/front-end      LoadBalancer   10.245.114.199   <pending>     80:30001/TCP   2m5s
service/orders         ClusterIP      10.245.200.240   <none>        80/TCP         2m4s
service/orders-db      ClusterIP      10.245.156.207   <none>        27017/TCP      2m5s
service/payment        ClusterIP      10.245.89.114    <none>        80/TCP         2m3s
service/queue-master   ClusterIP      10.245.206.155   <none>        80/TCP         2m3s
service/rabbitmq       ClusterIP      10.245.252.5     <none>        5672/TCP       2m2s
service/shipping       ClusterIP      10.245.200.49    <none>        80/TCP         2m2s
service/user           ClusterIP      10.245.1.54      <none>        80/TCP         2m1s
service/user-db        ClusterIP      10.245.223.84    <none>        27017/TCP      2m1s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/carts          1/1     1            1           2m7s
deployment.apps/carts-db       1/1     1            1           2m8s
deployment.apps/catalogue      1/1     1            1           2m6s
deployment.apps/catalogue-db   1/1     1            1           2m7s
deployment.apps/front-end      4/4     4            4           2m6s
deployment.apps/orders         1/1     1            1           2m4s
```

The Load Balancer takes about four minutes to provision.

To Access Socks Shop 
* Obtain the external IP address of Socks Shop.
* `k -n sock-shop get svc front-end`
* The IP address under EXTERNAL-IP is the external IP address of Socks Shop
* Paste the EXTERNAL-IP into your web browser.
* You should see a e-commerce website called Socks Shop
* Login to the site with:
  * user: user
  * password: password
* Feel free to browse around and order some socks

## Grafana - UI

![image](https://user-images.githubusercontent.com/18049790/65003256-3c2ae580-d8e7-11e9-992d-30358d52e731.png)

### What is Grafana?
* Grafana is an open source metric analytics & visualization suite
* It is most commonly used for visualizing time series data for infrastructure and application analytics
* We will use it to observe the Socks Shop micro-service

### Access the Grafana UI
* Grafana is exposed via a DigitalOcean Load Balancer. 
* Get the IP address to access your Grafana instance by running the following in a terminal shell and copying the EXTERNAL-IP and pasting it into a browser.

`k -n prometheus-operator get svc prometheus-operator-grafana`

```
root@digital-ocean-droplet:~# k -n prometheus-operator get svc prometheus-operator-grafana
NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
prometheus-operator-grafana   LoadBalancer   10.245.220.96   139.59.223.226   80:30459/TCP   9m4s
```

* Paste the EXTERNAL-IP into your web browser.
* The default username and password are `admin` and `changeme` respectively.
* Once you have logged in the default Grafana Home dashboard will be displayed. 
* To see cluster specific graphs enabled in this stack go to the “Home” menu in the upper left hand corner of your Grafana web browser page. 

### Observing Socks Shop with Grafana

Top left click on `Home`

Under `General` select `Kubernetes / Compute Resources / Namespace(Pods)`
* datasource: Prometheus
* Namespace: sock-shop
* Top Right click Clock Icon with text `Last 1 hour`
  * Under Quick Ranges
    * Select `Last 5 minutes`
* Top Right click last icon that looks like Recycle Icon
  * In drop down select `5s`

Scroll down the page and observe the metrics for the Socks Shop micro-service
* CPU Usage
* CPU Quota
* Memory Usage
* Memory Quota

## Locust - Load Testing

### Install Python

`sudo apt-get update`

`sudo apt-get install python -y`

`sudo apt-get install python-pip -y`

`sudo apt-get install python-pip -y`

### What is [Locust?](https://locust.io/)
* Locust is an easy-to-use, distributed, user load testing tool. 
* It is intended for load-testing web sites (or other systems) and figuring out how many concurrent users a system can handle. 

### Install Locust

`python -m pip install locustio==0.13.5`

`python -m pip install gevent`

### Configure Locust
```
cd ~/ && mkdir locust && cd locust
wget https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/locustfile-socks-shop.py
```

Obtain the external IP address of Socks Shop.
* `k -n sock-shop get svc front-end`
* The IP address under EXTERNAL-IP is the external IP address of Socks Shop.
* Use that address to stress test the micro-services application.

Start locust with this command: `locust -f ~/locust/locustfile-socks-shop.py --host=http://<EXTERNAL-IP> &`

Obtain the external IP address of `digital-ocean-droplet`
* `doctl compute droplet list`
* Get the `Public IPv4` for `digital-ocean-droplet`

Browse to : `http://<Public IPv4>:8089/`
* Enter these values 
  * Number of Users to Simulate: 500
  * Hatch Rate: 10

On main panel select `Charts`
* Top Right note Failures are 0%
* Keep the browser window open.

## Helm - Package Manager 

### What is Helm?
* Helm is an application package manager running atop Kubernetes. 
* It allows describing the application structure through helm-charts and managing those charts it with simple commands

### Install Helm 
```
cd && mkdir helm && cd helm
curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```
### Configure Helm
```
k create serviceaccount -n kube-system tiller
k create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init
k --namespace kube-system patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```

## Gremlin - Chaos

### What is Gremlin?
* Software as a Service Choas Engineering Platform 
* Chaos Engineering is the discipline of experimenting on a distributed system in order to build confidence in the system’s capability to withstand turbulent conditions in production.

### Install and Configure Gremlin

Create a gremlin directory
```
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
  * `doctl compute droplet list`
  * Get the `Public IPv4` for `digital-ocean-droplet`
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
k create ns gremlin
k create secret generic gremlin-team-cert --from-file=./gremlin.cert --from-file=./gremlin.key -n gremlin
```

### Install Gremlin

Let Gremlin know your Gremlin team ID and your Kubernetes cluster name
```
export GREMLIN_TEAM_ID="changeit"
export GREMLIN_CLUSTER_ID=digital-ocean-cluster
```

* Replace `"changeit"` with the value from the [Gremlin page](https://app.gremlin.com/signup) 
  * Obtain `GREMLIN_TEAM_ID` here: 
    * Top Right click on `Company Settings`
    * Click `Teams` tab
    * Click on your User
    * Click on Configuration
    * Your `Team ID` should be on the top row
    * Your `Team ID` is your `GREMLIN_TEAM_ID`

Add the Gremlin helm chart
```
helm repo remove gremlin
helm repo add gremlin https://helm.gremlin.com
```

Install the Gremlin Kubernetes client
```
helm install \
	--namespace gremlin \
	--name gremlin \
	gremlin/gremlin \
	--set gremlin.teamID=$GREMLIN_TEAM_ID \
	--set gremlin.clusterID=$GREMLIN_CLUSTER_ID
```

### Verify Gremlin is working

`watch -n 1 kubectl get all -n gremlin`

You should see similar output to the following.
```
```Every 1.0s: kubectl get all -n gremlin                                                 digital-ocean-droplet: Thu Oct 17 08:58:29 201

9

NAME                               READY   STATUS    RESTARTS   AGE
pod/fantastic-pika-gremlin-5sl76   1/1     Running   0          94s
pod/fantastic-pika-gremlin-dfttw   1/1     Running   0          94s
pod/fantastic-pika-gremlin-tv64w   1/1     Running   0          94s

NAME                                    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/fantastic-pika-gremlin   3         3         3       3            3           <none>          94s
```

## Practical - High CPU Resource Attack

### Start the User Interfaces

#### Locust
* Locust should still be running from a previous step.
  * `doctl compute droplet list`
  * Get the `Public IPv4` for `digital-ocean-droplet`
  * Browse to : `http://<Public IPv4>:8089/`

#### Grafana 
* Grafana should still be running from a previous step.
  * `k -n prometheus-operator get svc prometheus-operator-grafana`
  * Put `EXTERNAL-IP` into a browser.

#### Gremlin
* Login to [Gremlin](https://app.gremlin.com/signup)

### High CPU Attack
* Switch to the Locust UI 
  * Check the Locust UI switch to the charts view if required.
  * Reload the page if required

![locust-1](https://user-images.githubusercontent.com/18049790/66459128-f8229f00-eaa6-11e9-9fdb-f5cf07e591e4.png)

* Switch to the Grafana UI 
  * Top left click on `Home`
  * Under General
    * `USE Method / Node`
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
      * Interface will indicated `3 of 3 HOSTS TARGETED`
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
* Kubernetes is ensuring the the Socks Shop micro-service is high resilient and available 
* Locust is hitting the Socks Shop front-end container and reporting `0%` failures.

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
 
## Wrap Up
* You deployed a Kubernetes Cluster on Digital Ocean with Prometheus and Grafana pre-installed and configured.
* You deployed a micro-services application called Socks Shop to run on the Cluster.
* You observed metrics from the micro-services application with Prometheus and Grafana.
* You deployed a performance tool called Locust to stress test the micro-services application and observe any failures.
* You installed Gremlin to perform a Chaos Experiment (CPU Resource Attack) on the micro-services application.

## Kube Monkey - Chaos - Optional

```diff
- This part is under development and may potentially not work -
```

### What is Kube Monkey? 
* Kube Monkey is an implementation of Netflix's chaos monkey for kubernetes clusters. 
* It schedules randomly killing of pods in order to test fault tolerance of a highly available system.

### Install Kube Monkey

* `k apply -n sock-shop -f "https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/kube-monkey-rbac-socks-shop.yml"`

* `k apply -n sock-shop -f "https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/kube-monkey-front-end.yml"`

* `k apply -n sock-shop -f "https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/kube-monkey-cm-socks-shop.yml"`

* `k apply -n sock-shop -f "https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/kube-monkey-deploy-socks-shop.yml"`

To verify that everything is working as expected use this command: `watch -n1 kubectl get deployments -n sock-shop`

Check that `kube-monkey` is present and `front-end` shows READY as 4/4.
```
Every 1.0s: kubectl get deployments -n sock-shop                                       digital-ocean-droplet: Mon Nov 11 06:04:08 2019

NAME           READY   UP-TO-DATE   AVAILABLE   AGE
carts          1/1     1            1           41m
carts-db       1/1     1            1           41m
catalogue      1/1     1            1           41m
catalogue-db   1/1     1            1           41m
front-end      4/4     4            4           41m
kube-monkey    1/1     1            0           6m41s
orders         1/1     1            1           41m
orders-db      1/1     1            1           41m
payment        1/1     1            1           41m
queue-master   1/1     1            1           41m
rabbitmq       1/1     1            1           41m
shipping       1/1     1            1           41m
user           1/1     1            1           41m
user-db        1/1     1            1           41m
```

To verify that Kube Monkey is working: `k get pods -n sock-shop`

```
NAME                            READY   STATUS    RESTARTS   AGE
carts-56c6fb966b-nrwx4          1/1     Running   0          23h
carts-db-5678cc578f-w99cf       1/1     Running   0          23h
catalogue-644549d46f-mpwrz      1/1     Running   0          23h
catalogue-db-6ddc796b66-rbp7h   1/1     Running   0          23h
front-end-6f9db4fd44-6mcw7      1/1     Running   0          21h
front-end-6f9db4fd44-7n228      1/1     Running   0          21h
front-end-6f9db4fd44-bn6t6      1/1     Running   0          21h
front-end-6f9db4fd44-lsm6z      1/1     Running   0          21h
kube-monkey-6b7c69cdd5-tt24h    1/1     Running   0          19h
orders-749cdc8c9-kqhsw          1/1     Running   0          23h
orders-db-5cfc68c4cf-pf7sq      1/1     Running   0          23h
payment-54f55b96b9-8x8z2        1/1     Running   0          23h
queue-master-6fff667867-fkxj6   1/1     Running   0          23h
rabbitmq-bdfd84d55-nx495        1/1     Running   0          23h
shipping-78794fdb4f-9fvfv       1/1     Running   0          23h
user-77cff48476-lk4rs           1/1     Running   0          23h
user-db-99685d75b-mzhqv         1/1     Running   0          23h
```

Using the name of the Kube Monkey pod get its logs: `k logs kube-monkey-xxxxxxxxxx`

```
I0925 03:09:18.205972       1 kubemonkey.go:62] Status Update: Waiting to run scheduled terminations.
I0925 03:10:05.235847       1 victims.go:130] [DryRun Mode] Terminated pod front-end-6f9db4fd44-6mcw7 for sock-shop/front-end
I0925 03:10:05.236113       1 victims.go:130] [DryRun Mode] Terminated pod front-end-6f9db4fd44-7n228 for sock-shop/front-end
I0925 03:10:05.236215       1 kubemonkey.go:70] Termination successfully executed for v1.Deployment front-end
I0925 03:10:05.236298       1 kubemonkey.go:73] Status Update: 0 scheduled terminations left.
I0925 03:10:05.236352       1 kubemonkey.go:76] Status Update: All terminations done.
I0925 03:10:05.236519       1 kubemonkey.go:19] Debug mode detected!
I0925 03:10:05.236594       1 kubemonkey.go:20] Status Update: Generating next schedule in 30 sec
I0925 03:10:35.236843       1 schedule.go:64] Status Update: Generating schedule for terminations
I0925 03:10:35.257632       1 schedule.go:57] Status Update: 1 terminations scheduled today
I0925 03:10:35.257848       1 schedule.go:59] v1.Deployment front-end scheduled for termination at 09/24/2019 23:11:32 -0400 EDT
        ********** Today's schedule **********
        k8 Api Kind     Kind Name               Termination Time
        -----------     ---------               ----------------
        v1.Deployment   front-end               09/24/2019 23:11:32 -0400 EDT
        ********** End of schedule **********
```

Look for these messages that indicate successful deployment: `[DryRun Mode] Terminated pod front-end-xxxxxx for sock-shop/front-end`

## Tutorial Clean Up 

Two methods to clean up
* GUI 
* CLI

### CLI Method

Delete Kubernetes Cluster
* `doctl kubernetes cluster delete digital-ocean-cluster`

Delete Kubernetes Cluster
* `doctl compute load-balancer list`
  * Get ID for each Load Balancer
* `doctl compute load-balancer delete <ID>`
  * Confirm with `y`
  
Delete Droplet  
* `doctl compute droplet delete digital-ocean-droplet`  

### GUI Method

Login to Digital Ocean

### Kubernetes 
* Left side bar select Kubernetes
* Select your cluster 
* Top right select `Actions` button
* Select `Destroy`
* On next page confirm by selecting `Destroy` again
* Enter `digital-ocean-cluster` to enable deletion

### Load Balancer
* Left side bar select Networking
* Select Load Balancers
* Select the top Load Balancer
* Select Settings
* Scroll to bottom and select Destroy
* Select the Confirm button 
* Repeat for all Load Balancers

### Droplet
* Left side bar select "Manage".."Droplets"
* On right side of `digital-ocean-droplet` select `More` button
* Select `Destroy`
* Select `Destroy` again

## Theory 

### Prometheus Theory - Time Series Database
![logo_prom](https://user-images.githubusercontent.com/18049790/64942965-faa02900-d859-11e9-8f2b-730b9851c763.png)

Prometheus is an embedded and pre-configured compeonent so it only has a theory section.

#### What is Prometheus?
* Prometheus is an open-source *systems monitoring and alerting* toolkit originally built at SoundCloud. 
* It is now a standalone open source project and maintained independently of any company. 
* Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

#### Prometheus's main features are:
* a multi-dimensional data model with **time series data** identified by metric name and key/value pairs
* PromQL, a flexible query language to leverage this dimensionality
* no reliance on distributed storage; single server nodes are autonomous
* time series collection happens via a **pull model over HTTP**
* pushing time series is supported via an intermediary gateway
* targets are discovered via service discovery or static configuration
* multiple modes of graphing and dashboarding support

#### Prometheus Components
* the main Prometheus server which scrapes and stores time series data
* client libraries for instrumenting application code
* a push gateway for supporting short-lived jobs
* special-purpose exporters for services like HAProxy, StatsD, Graphite, etc.
* an alertmanager to handle alerts
* various support tools

Most Prometheus components are written in Go, making them easy to build and deploy as static binaries.

#### Prometheus Architecture

This diagram illustrates the architecture of Prometheus and some of its ecosystem components:

Credit to [Prometheus](https://prometheus.io/docs/introduction/overview/)

![prom-architecture](https://user-images.githubusercontent.com/18049790/64942969-fd028300-d859-11e9-9b13-20b7d6f14069.png)

## metrics-server Theory - Kubernetes Metrics

The metrics-server is an embedded and pre-configured compeonent so it only has a theory section.

The metrics-server provides cluster metrics, such as container CPU and memory usage via the Kubernetes Metrics API.

To view the metrics made available by metrics server, run the following command in a terminal shell:

`k top nodes`

```
[jamesbuckett@surface ~ (digital-ocean-cluster:sock-shop)]$ k top nodes
NAME                      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
digital-ocean-pool-bdy6   269m         26%    1438Mi          91%
digital-ocean-pool-bdyl   164m         16%    1296Mi          82%
digital-ocean-pool-bdyt   186m         18%    1427Mi          90%
```

or for the Socks Shop Namespaces enter:

`k top pods -n sock-shop`

```
[jamesbuckett@surface ~ (digital-ocean-cluster:sock-shop)]$ k top pods -n sock-shop
NAME                            CPU(cores)   MEMORY(bytes)
carts-56c6fb966b-nrwx4          3m           268Mi
carts-db-5678cc578f-w99cf       5m           79Mi
catalogue-644549d46f-mpwrz      1m           5Mi
catalogue-db-6ddc796b66-rbp7h   1m           196Mi
front-end-6f9db4fd44-6mcw7      30m          74Mi
front-end-6f9db4fd44-7n228      20m          68Mi
front-end-6f9db4fd44-bn6t6      28m          66Mi
front-end-6f9db4fd44-lsm6z      25m          79Mi
kube-monkey-6b7c69cdd5-tt24h    0m           7Mi
orders-749cdc8c9-kqhsw          2m           258Mi
orders-db-5cfc68c4cf-pf7sq      5m           67Mi
payment-54f55b96b9-8x8z2        1m           1Mi
queue-master-6fff667867-fkxj6   2m           148Mi
rabbitmq-bdfd84d55-nx495        1m           67Mi
shipping-78794fdb4f-9fvfv       2m           252Mi
user-77cff48476-lk4rs           1m           3Mi
user-db-99685d75b-mzhqv         8m           35Mi
```

[Meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)
* Limits and requests for memory are measured in bytes. 
* You can express memory as a plain integer or as a fixed-point integer using one of these suffixes: E, P, T, G, M, K. 
* You can also use the power-of-two equivalents: Ei, Pi, Ti, Gi, **Mi**, Ki. 

[Meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)
* Limits and requests for CPU resources are measured in cpu units. 
* One cpu, in Kubernetes, is equivalent to:
 * 1 AWS vCPU
 * 1 GCP Core
 * 1 Azure vCore
 * 1 IBM vCPU
 * 1 Hyperthread on a bare-metal Intel processor with Hyperthreading

As metrics server is running on your cluster you can also see metrics in the DigitalOcean Kubernetes Dashboard. 

To see your cluster metrics 
* go to https://cloud.digitalocean.com/kubernetes/clusters
* click on your cluster 
* click on “Insights” tab

![do-cluster-insights](https://user-images.githubusercontent.com/18049790/65855878-b13ff580-e392-11e9-91dc-92ed31bbddad.png)

For additional information on metrics-server see https://github.com/kubernetes-incubator/metrics-server.

### Documentation 
* [Kubernetes](https://kubernetes.io)
* [Prometheus](https://prometheus.io)
* [Grafana](https://grafana.com)
* [Prometheus NodeExporter](https://github.com/prometheus/node_exporter/blob/master/README.md)
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/blob/master/README.md)
* [metrics-server](https://github.com/kubernetes-incubator/metrics-server/blob/master/README.md)
* [Gremlin](https://www.gremlin.com/)
* [Locust](https://locust.io/)

### Buzz Words
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
