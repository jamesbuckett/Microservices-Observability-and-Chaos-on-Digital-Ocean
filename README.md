# A Tutorial on Microservices, Observability and Chaos on Digital Ocean 

![image](https://user-images.githubusercontent.com/18049790/43352583-0b37edda-9269-11e8-9695-1e8de81acb76.png)

### Table of Contents
* Introduction
  * Agenda
  * Requirements
  * Cost Warning
* Digital Ocean (Cloud Provider)
  * Setup Digital Ocean Project
  * SSH Setup
  * Setup Digital Ocean Droplet
  * Deploy Digital Ocean Kubernetes cluster
  * Accessing the Digital Ocean Kubernetes cluster
    * doctl (Digital Ocean Command Line Interface)
    * kubectl (Kubernetes Command Line Interface)
* Socks Shop (Micro-service)
* Grafana (Metrics UI)
  * Observing Socks Shop with Grafana
* Locust (Performance Tool)
* Helm (Package Manager)
  * Install Helm
  * Configure Helm
* Gremlin (Chaos)
  * Install Gremlin
  * Verify Gremlin is working
* Practical - The Fun Starts Here
  * Start User Interfaces
    * Locust
    * Grafana
    * Gremlin
  * High CPU Attack
  * Wrap Up
* Tutorial Clean Up
  * CLI Method
  * GUI Method
* Theory
  * Prometheus Theory - Time Series Database 
  * metrics-server Theory - Kubernetes Metrics
  * Documentation
  * Buzz Words

## Introduction

### Agenda
* Deploy a Kubernetes cluster on Digital Ocean with Observability software pre-configured
* Deploy the Socks Shop micro-services application onto the Kubernetes cluster on Digital Ocean
* Verify operation of the Socks Shop micro-service
* Observe the Socks Shop micro-service with the Observability software
* Perform Chaos Engineering on the Socks Shop micro-service

### Requirements
* A Digital Ocean Account
* A Terminal Emulator to interact with the cluster
  * Windows 10
    * [PuTTY](https://www.putty.org/)
    * [PuTTYgen](https://www.puttygen.com/)
  * Mac  
    * [Terminal on Mac](https://support.apple.com/en-sg/guide/terminal/welcome/mac)

### Cost Warning
Note: This stack requires a minimum configuration of
* 2 * Nodes at $10/month (2GB memory / 1 vCPU) 
* 2 * Load Balancer at $10/month 
* 1 * Droplet at $40/month
* **Total cost of $80 per month if kept running**

```diff
- Please tear all infrastructure at the end of this tutorial or you will incur a cost at the end of the month -
```

## Digital Ocean - Cloud Provider

### Setup a Digital Ocean Project
* Go to [Digital Ocean](https://www.digitalocean.com) and sign up or login.
  * Use this [referral link](https://m.do.co/c/ac62c560d54a) to get $50 in credit 
* Create a new Project called : `digital-ocean-project`
* Make sure you select the Project called `digital-ocean-project` and proceed to next step

### Setup SSH
* Follow this guide to create and upload SSH keys required to access Digital Ocean
  * [How-to Add SSH Keys to New or Existing Droplets](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/)
* Upload the public key to Digital Ocean as `digital-ocean-public-key`

### Setup Digital Ocean Droplet
* Go to "Manage".."Droplets" on the left tab
* Select create `Droplet`
* Choose an image..Distributions..`Ubuntu`
* Choose a plan..`Standard`
* Choose a datacentre region: `Singapore`
* Authentication..`SSH Key` should already be selected
* Choose a hostname: `digital-ocean-droplet`
* Select Project is set to `Digital Ocean Project`
* Go to bottom of page and select "Create Droplet"
  * Droplet build usually takes four minutes

### Accessing Digital Ocean Droplet
* In the `digital-ocean-project` page locate the Droplet called `digital-ocean-droplet`
* Copy the IP address by hovering on the IP Address of `digital-ocean-droplet` a `copy` pop-up will appear
* Paste the IP address into Putty Host Box
* Add your Private Key Category..SSH..Auth
  * Private Key for Authentication
  
### Digital Ocean Kubernetes cluster
* Go to "Discover".."Marketplace" on the left tab.
* Under "Find a Solution" click the "Kubernetes - New" tab.
* Click the "[Kubernetes Monitoring Stack](https://cloud.digitalocean.com/marketplace/5d163fdd29a6ab0d4c7d5274?i=9ca3ac)"
* Select "Create Cluster"
* Choose a datacentre region: `Singapore`
* Choose a name: 
  * Enter Cluster name: `digital-ocean-cluster`
* Go to bottom of page and select "Create Cluster"
  * Cluster build usually takes four minutes

Go back to the main page to confirm that the cluster and load balancer have been created before proceeding.
* At the top of the page the cluster name `digital-ocean-cluster` will have a green icon indicating it is ready for use.
* Scroll to the top of the page and check for green icon on the digital-ocean-cluster name.

```diff
- Wait for the cluster to be ready before continuing, check for green icon on cluster name -
```

### Accessing the Digital Ocean Kubernetes cluster 

The Digital Ocean Kubernetes cluster will be managed from `digital-ocean-droplet`. 

Two binaries need to be installed on `digital-ocean-droplet` to interact with the cluster:
* `doctl`
* `kubectl`

#### doctl - Digital Ocean Command Line Interface

Installation [Link](https://github.com/digitalocean/doctl#installing-doctl)

* doctl Installation
```
cd ~/ && mkdir doctl && cd doctl
curl -sL https://github.com/digitalocean/doctl/releases/download/v1.17.0/doctl-1.17.0-linux-amd64.tar.gz | tar -xzv
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
  * Add the digital-ocean-cluster credentials to kubeconfig
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
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

Set the alias
```
kubectl config use-context do-sgp1-digital-ocean-cluster
alias k='kubectl'
k version
```

* Use 'k version' to make sure that your installation is working and within one minor version of your cluster.

```
root@digital-ocean-droplet:~# k version
Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.2", GitCommit:"c97fe5036ef3df2967d086711e6c0c405941e14b", GitTreeState:"clean", BuildDate:"2019-10-15T19:18:23Z", GoVersion:"go1.12.10", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.4", GitCommit:"67d2fcf276fcd9cf743ad4be9a9ef5828adc082f", GitTreeState:"clean", BuildDate:"2019-09-18T14:41:55Z", GoVersion:"go1.12.9", Compiler:"gc", Platform:"linux/amd64"}
```

## Socks Shop - Micro-service

[Socks Shop](https://microservices-demo.github.io) 
* This project provides a realistic micro-services oriented e-commerce application. 
* See the diagram below for the diverse languages, frameworks and databases used in the microservices application.

![image](https://user-images.githubusercontent.com/18049790/65854068-1d6c2a80-e38e-11e9-9337-cc398eb9a1f0.png)
Credit to [Learn Micro-service from Sock Shop](https://medium.com/@panan_songyu/learn-micro-service-from-sock-shop-1-d80e815f3394)

To install the Socks Shop Application 
* Create a namespace for sock shop.
* `k create namespace sock-shop`
* `k apply -n sock-shop -f "https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/complete-demo.yaml"`

Run this command : `watch -n 1 kubectl get all -n sock-shop`

Watch the output until this line changes 
* from : `service/front-end      LoadBalancer   x.x.x.x      <pending>     80:30001/TCP   2m5s`
* to   : `service/front-end      LoadBalancer   x.x.x.x      x.x.x.x       80:30001/TCP   3m15s`

Where x.x.x.x is a valid EXTERNAL-IP which is the IP to access your Socks Shop micro-service.

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

Grafana is exposed via a DigitalOcean Load Balancer. 

Get the IP address to access your Grafana instance by running the following in a terminal shell and copying the EXTERNAL-IP and pasting it into a browser.

`k -n prometheus-operator get svc prometheus-operator-grafana`

```
root@digital-ocean-droplet:~# k -n prometheus-operator get svc prometheus-operator-grafana
NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
prometheus-operator-grafana   LoadBalancer   10.245.220.96   139.59.223.226   80:30459/TCP   9m4s
```

Paste the EXTERNAL-IP into your web browser.

The default username and password are `admin` and `changeme` respectively.

Once you have logged in the default Grafana Home dashboard will be displayed. 

To see cluster specific graphs enabled in this stack go to the “Home” menu in the upper left hand corner of your Grafana web browser page. 

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

Scroll down the page and see metrics for Socks Shop
* CPU Usage
* CPU Quota
* Memory Usage
* Memory Quota

## Locust - Performance 

Install Python

```
sudo apt-get update
sudo apt-get install python -y
sudo apt-get install python3-pip -y
```

Install [Locust](https://locust.io/)

`python -m pip install locustio`

Restart terminal for install to complete

Configure Locust: 
```
cd ~/ && mkdir locust && cd locust
wget https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/locustfile-socks-shop.py
```

Obtain the external IP address of Socks Shop.
* `k -n sock-shop get svc front-end`
* The IP address under EXTERNAL-IP is the external IP address of Socks Shop.
* Use that address to stress the micro-services application.

Start locust with this command: `locust -f ~/locust/locustfile-socks-shop.py --host=http://<EXTERNAL-IP> &`

Browse to : `http://127.0.0.1:8089/`
* Enter these values 
  * Number of Users to Simulate: 500
  * Hatch Rate: 10

On main panel select `Charts`
* Top Right note Failures are 0%
* Keep the browser window open.

## Helm - Package Manager 

### Install Helm 
```
mkdir helm
cd helm
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

## Gremlin 

Create a gremlin directory
```
cd 
mkdir gremlin
cd gremlin
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
  * If on Windows using WSL download the `certificate.zip` file to c:\Users\<your-name>\Downloads
    * `cp /mnt/c/Users/<your-name>/Downloads/certificate.zip /home/<your-name>/gremlin/.`
  * If on Mac download the `certificate.zip` to the `~/gremlin` directory.
    * Save the file to `~/gremlin`
* The downloaded `certificate.zip` contains both a public-key certificate and a matching private key.
* Unzip the `certificate.zip`
* Rename your certificate and key files to gremlin.cert and gremlin.key.
```
cd ~/gremlin
sudo apt-get install unzip
unzip certificate.zip
mv *.priv_key.pem gremlin.key
mv *.pub_cert.pem gremlin.cert
```
Create a secret from the files
```
k create ns gremlin
k create secret generic gremlin-team-cert --from-file=./gremlin.cert --from-file=./gremlin.key -n gremlin
helm repo add gremlin https://helm.gremlin.com
```

### Install Gremlin
* Replace `ID=YOUR-TEAM-ID` with the value from the Gremlin page 
  * Obtain YOUR-TEAM-ID here: 
    * Top Right click on `Company Settings`
    * Click `Teams` tab
    * Click on your User
    * Click on Configuration
    * Your `Team ID` should be on the top row
```
helm install --namespace gremlin  --set gremlin.teamID=YOUR-TEAM-ID gremlin/gremlin 
```

### Verify Gremlin is working

`watch -n 1 kubectl get all -n gremlin`

You should see similar output to the following.
```
Every 1.0s: kubectl get all -n gremlin                                                               surface: Mon Oct 14 11:06:31 2019

NAME                               READY   STATUS    RESTARTS   AGE
pod/virtuous-molly-gremlin-cb9gn   1/1     Running   0          86s
pod/virtuous-molly-gremlin-m8bbg   1/1     Running   0          86s
pod/virtuous-molly-gremlin-pmwzs   1/1     Running   0          86s

NAME                                    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/virtuous-molly-gremlin   3         3         3       3            3           <none>          87s
```

## Practical - The Fun Starts Here

### Start the User Interfaces

#### Locust
* Locust should still be running from a previous step.
  * `http://127.0.0.1:8089/`

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
  * Select `Kubernetes / Nodes`
  * Top Right click Clock Icon with text Last 1 hour
    * Select Last 5 minutes
  * Top Right click last icon that looks like Recycle Icon
    * In drop down select 5s
  
![grafana-1](https://user-images.githubusercontent.com/18049790/66459139-fd7fe980-eaa6-11e9-9ff4-6eac75f92742.png)  
  
* Switch to the Gremlin UI
  * Left side select `Attacks`
  * Select `Infrastructure`
  * Select `New Attack`
  * Scroll down select `Choose a Gremlin`
  * Under `Category` select `Resource`
    * Next to `Length` enter `180`
    * Next to `CPU Capacity` enter `100`
  * Scroll to bottom of page select `Unleash Gremlin`
  
* Switch to the Grafana UI
  * Observe the Nodes reaching 100% utilization 
  * Top use the `instance` dropdown to views other Nodes.
  
  ![grafana-2](https://user-images.githubusercontent.com/18049790/66459191-20aa9900-eaa7-11e9-875a-f64b9c9ff163.png)
  
* Switch to the Locust UI
  * Observe top right that `Failures` are 0%

![locust-2](https://user-images.githubusercontent.com/18049790/66459196-2607e380-eaa7-11e9-8ec4-e7401441697b.png)

You have successfully performed a CPU Resource Attack against the infrastrucure nodes.

What you are observing is the following:
* Gremlin is causing the Nodes to go to 100% CPU utilization
* Kubernetes is ensuring the the Socks Shop micro-service is high resilient and available 
* Locust is hitting the Socks Shop front-end and reporting 0% failures.

Optional Rerun
* On the Gremlin UI click the attack
* Top right click `Rerun`
* Scroll to bottom of page and select `Unleash Gremlin`
* Switch to the Grafana UI 
  * Top left click on `Home`
  * Select `Kubernetes / Compute Resources / Cluster`
  * Top Right click Clock Icon with text Last 1 hour
    * Select Last 5 minutes
  * Top Right click last icon that looks like Recycle Icon
    * In drop down select 5s
* This is the aggregate view of the Kubernetes cluster resources.
  * In the `CPU Usage` view note how the `gremlin` namespace is consuming CPU cycles.
 
## Wrap Up
* You deployed a Kubernetes Cluster on Digital Ocean with Prometheus and Grafana pre-installed and configured.
* You deployed a microservices application called Socks Shop to run on the Cluster.
* You observed metrics from the micro-services application with Prometheus and Grafana.
* You deployed a performance tool called Locust to stress test the micro-services application and observe any failures.
* You installed Gremlin to perform a Chaos Experiment (CPU Resource Attack) on the micro-services application.

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
* `doctl compute droplet list`
  * Get ID for `digital-ocean-droplet`
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
* Limits and requests for CPU resources are measured in cpu units. One cpu, in Kubernetes, is equivalent to:
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
