# A Tutorial on Microservices, Observability and Chaos on Digital Ocean 

![image](https://user-images.githubusercontent.com/18049790/43352583-0b37edda-9269-11e8-9695-1e8de81acb76.png)

## Agenda
* Deploy a Kubernetes cluster on Digital Ocean with Observability software pre-configured
* Deploy the Socks Shop micro-services application onto the Kubernetes cluster on Digital Ocean
* Verify operation of the Socks Shop micro-service
* Observe the Socks Shop micro-service with the Observability software
* Perform Chaos Engineering on the Socks Shop micro-service

## Requirements
* A Digital Ocean Account
* A Linux terminal to interact with the cluster
* A sense of humour

## Buzz Words
* Digital Ocean - Developer focused Cloud Provider.
* Micro-service - Collection of **loosely coupled services** that are **independently deployable and scalable**.
* Kubernetes - Open-source self-healing platform to deploy, scale and operate containers.
* Prometheus - Prometheus is an open source toolkit to monitor and alert.
* Grafana - Grafana offers data visualization & Monitoring with support for Graphite, InfluxDB, Prometheus.
* Kube State Metrics - A simple service that listens to the Kubernetes API server and generates metrics about the state of the objects. 
* Prometheus NodeExporter - UNIX/Linux hardware and Operating System metrics.
* Kubernetes Metrics Server - Kubernetes resource usage metrics, such as container CPU and memory usage, are available in Kubernetes through the Metrics API.
* Kube Monkey - Kube-Monkey periodically kills pods in your Kubernetes cluster,that are opt-in based on their own rules.
* Locust - A performance testing tool 

## Documentation 
* [Kubernetes](https://kubernetes.io)
* [Prometheus](https://prometheus.io)
* [Grafana](https://grafana.com)
* [Prometheus NodeExporter](https://github.com/prometheus/node_exporter/blob/master/README.md)
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/blob/master/README.md)
* [metrics-server](https://github.com/kubernetes-incubator/metrics-server/blob/master/README.md)
* [Kube Monkey](https://github.com/asobti/kube-monkey)
* [Locust](https://locust.io/)

## Tutorial Description

This Tutorial will give you hands on deployment and operation of the following technologies:
* Digital Ocean
* Kubernetes
* Prometheus
* Grafana
* Kube Monkey
* Locust

## Cost Warning

Note: This stack requires a minimum configuration of
* 2 * Nodes at $10/month (2GB memory / 1 vCPU) 
* 2 * Load Balancer at $10/month 
* **Total cost of $40 per month if kept running**

```diff
- Please tear all infrastructure at the end of this tutorial or you will incur a cost at the end of the month -
```

## Digital Ocean - Cloud Provider

![image](https://user-images.githubusercontent.com/18049790/43352593-2dbb84de-9269-11e8-9ae9-374690064767.png)

Installation:
* Go to [Digital Ocean](https://www.digitalocean.com) and sign up or login.
  * Use this [referral link](https://m.do.co/c/ac62c560d54a) to get $10 in credit 
* Create a new Project called : `digital-ocean-project`
* Go to "Marketplace" on the left tab.
* Under "Find a Solution" click the "Kubernetes" tab.
* Click the "[Kubernetes Monitoring Stack](https://cloud.digitalocean.com/marketplace/5d163fdd29a6ab0d4c7d5274?i=9ca3ac)"
* Select "Create Cluster"
* Choose a datacentre region: `Singapore`
* Choose a name: `digital-ocean-cluster`
* Go to bottom of page and select "Create Cluster"
  * Cluster build usually takes four minutes
* On Getting Started Panel go to "3. Download the config file"
* Make the .kube directory: `mkdir ~/.kube`
* Under "Quick connect with manual certificate management" select "download the cluster configuration file"
* Download the `kubeconfig.yaml` to the `~/.kube` directory.
 * The authentication certificate in kubeconfig.yaml expires seven days after download

Go back to the main page to confirm that the cluster and load balancer have been created before proceeding.

### Accessing the Digital Ocean Kubernetes cluster 

Digital Ocean Kubernetes clusters are typically managed from a local machine or sometimes from a remote management server. 

`kubectl` is a command line tool used to interact with Kubernetes clusters.

In the diagram below you see `kubectl` interacts with the Kubernetes API Server.

![image](https://user-images.githubusercontent.com/18049790/65854426-30332f00-e38f-11e9-89a9-b19cc005db91.png)
Credit to [What is Kubernetes](https://www.learnitguide.net/2018/08/what-is-kubernetes-learn-kubernetes.html)

In your terminal that you will use to interact with the Digital Ocean Kubernetes cluster install `kubectl`.

#### kubectl installation

* [kubectl](https://kubernetes.io/docs/reference/kubectl/overview) is the official Kubernetes command-line tool, which you’ll use to connect to and interact with the cluster.
* The Kubernetes project provides [installation instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl) for kubectl on a variety of platforms. 

Once kubectl is installed setup an alias to call kubectl with the Digital Ocean Kubeconfig file

Linux and Mac
```
alias k='cd ~/.kube && kubectl --kubeconfig="digital-ocean-cluster-kubeconfig.yaml"'
k version
```

* Use 'k version' to make sure that your installation is working and within one minor version of your cluster.

```
[jamesbuckett@surface ~ (digital-ocean-cluster:sock-shop)]$ k version
Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.0", GitCommit:"2bd9643cee5b3b3a5ecbd3af49d09018f0773c77", GitTreeState:"clean", BuildDate:"2019-09-18T14:36:53Z", GoVersion:"go1.12.9", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.3", GitCommit:"2d3c76f9091b6bec110a5e63777c332469e0cba2", GitTreeState:"clean", BuildDate:"2019-08-19T11:05:50Z", GoVersion:"go1.12.9", Compiler:"gc", Platform:"linux/amd64"}
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

Use this command to verify a successful deployment: `k get all -n sock-shop`

```
[jamesbuckett@surface ~ (digital-ocean-cluster:sock-shop)]$ k get all -n sock-shop
NAME                                READY   STATUS    RESTARTS   AGE
pod/carts-56c6fb966b-nrwx4          1/1     Running   0          22h
pod/carts-db-5678cc578f-w99cf       1/1     Running   0          22h
pod/catalogue-644549d46f-mpwrz      1/1     Running   0          22h
pod/catalogue-db-6ddc796b66-rbp7h   1/1     Running   0          22h
pod/front-end-6f9db4fd44-6mcw7      1/1     Running   0          19h
pod/orders-749cdc8c9-kqhsw          1/1     Running   0          22h
pod/orders-db-5cfc68c4cf-pf7sq      1/1     Running   0          22h
pod/payment-54f55b96b9-8x8z2        1/1     Running   0          22h
pod/queue-master-6fff667867-fkxj6   1/1     Running   0          22h
pod/rabbitmq-bdfd84d55-nx495        1/1     Running   0          22h
pod/shipping-78794fdb4f-9fvfv       1/1     Running   0          22h
pod/user-77cff48476-lk4rs           1/1     Running   0          22h
pod/user-db-99685d75b-mzhqv         1/1     Running   0          22h

NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)        AGE
service/carts          ClusterIP      10.245.9.190     <none>         80/TCP         22h
service/carts-db       ClusterIP      10.245.183.3     <none>         27017/TCP      22h
service/catalogue      ClusterIP      10.245.157.236   <none>         80/TCP         22h
service/catalogue-db   ClusterIP      10.245.2.69      <none>         3306/TCP       22h
service/front-end      LoadBalancer   10.245.255.112   x.x.x.x        80:30001/TCP   22h
service/orders         ClusterIP      10.245.71.35     <none>         80/TCP         22h
service/orders-db      ClusterIP      10.245.227.95    <none>         27017/TCP      22h
service/payment        ClusterIP      10.245.45.90     <none>         80/TCP         22h
service/queue-master   ClusterIP      10.245.21.101    <none>         80/TCP         22h
service/rabbitmq       ClusterIP      10.245.195.66    <none>         5672/TCP       22h
service/shipping       ClusterIP      10.245.2.73      <none>         80/TCP         22h
service/user           ClusterIP      10.245.188.69    <none>         80/TCP         22h
service/user-db        ClusterIP      10.245.194.49    <none>         27017/TCP      22h

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/carts          1/1     1            1           22h
deployment.apps/carts-db       1/1     1            1           22h
deployment.apps/catalogue      1/1     1            1           22h
deployment.apps/catalogue-db   1/1     1            1           22h
deployment.apps/front-end      4/4     4            4           22h
deployment.apps/kube-monkey    1/1     1            1           18h
deployment.apps/orders         1/1     1            1           22h
deployment.apps/orders-db      1/1     1            1           22h
deployment.apps/payment        1/1     1            1           22h
deployment.apps/queue-master   1/1     1            1           22h
deployment.apps/rabbitmq       1/1     1            1           22h
deployment.apps/shipping       1/1     1            1           22h
deployment.apps/user           1/1     1            1           22h
deployment.apps/user-db        1/1     1            1           22h

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/carts-56c6fb966b          1         1         1       22h
replicaset.apps/carts-db-5678cc578f       1         1         1       22h
replicaset.apps/catalogue-644549d46f      1         1         1       22h
replicaset.apps/catalogue-db-6ddc796b66   1         1         1       22h
replicaset.apps/front-end-5594987df6      0         0         0       22h
replicaset.apps/front-end-6f9db4fd44      4         4         4       19h
replicaset.apps/kube-monkey-6b7c69cdd5    1         1         1       18h
replicaset.apps/orders-749cdc8c9          1         1         1       22h
replicaset.apps/orders-db-5cfc68c4cf      1         1         1       22h
replicaset.apps/payment-54f55b96b9        1         1         1       22h
replicaset.apps/queue-master-6fff667867   1         1         1       22h
replicaset.apps/rabbitmq-bdfd84d55        1         1         1       22h
replicaset.apps/shipping-78794fdb4f       1         1         1       22h
replicaset.apps/user-77cff48476           1         1         1       22h
replicaset.apps/user-db-99685d75b         1         1         1       22h
```

The Load Balancer takes about four minutes to provision.

Run `k get all -n sock-shop` until you see `service/front-end` has a valid EXTERNAL-IP.

To Access Socks Shop 
* Obtain the external IP address of Socks Shop.
* `k -n sock-shop get svc front-end`
* The IP address under EXTERNAL-IP is the external IP address of Socks Shop
* Paste the EXTERNAL-IP or IP address found in the Load Balancer dashboard into your web browser.
* You should see a e-commerce website called Socks Shop
* Feel free to browse around and order some socks

## Grafana - UI

![image](https://user-images.githubusercontent.com/18049790/65003256-3c2ae580-d8e7-11e9-992d-30358d52e731.png)

Grafana is exposed via a DigitalOcean Load Balancer. 

You can get the IP address to access your Grafana instance either by looking for the IP within the Load Balancer dashboard, or by running the following in a terminal shell and copying the EXTERNAL-IP.

`k -n prometheus-operator get svc prometheus-operator-grafana`

```
[jamesbuckett@surface ~ (digital-ocean-cluster:sock-shop)]$ k -n prometheus-operator get svc prometheus-operator-grafana
NAME                          TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
prometheus-operator-grafana   LoadBalancer   10.245.70.78   139.x.x.x       80:30600/TCP   23h
```

Paste the EXTERNAL-IP or IP address found in the Load Balancer dashboard into your web browser.

The default username and password are `admin` and `changeme` respectively.

To change the password:
* Log into to Grafana with default username and password
* Click on the admin avatar in the bottom left in Grafana. (above the question mark)
* Click on preferences
* Click on Change password on middle tab
* Follow the instructions and click “Change password”

Once you have logged in the default Grafana Home dashboard will be displayed. 

To see cluster specific graphs enabled in this stack go to the “Home” menu in the upper left hand corner of your Grafana web browser page. 

### Observing Socks Shop with Grafana

Top left click on `Home`

Under `General` select `Kubernetes/Compute Resources/Namespace(Pods)`
* datasource: Prometheus
* Namespace: sock-shop
* Pod : front-end-xxxxxxxxxx (random numbers)
* Top Right click Clock Icon with text `Last 1 hour`
* Select `Last 5 minutes`
* Top Right click last icon that looks like Recycle Icon
* In drop down select `5s`

Explore other Prometheus datasource based Kubernetes dashboards at: https://grafana.com/dashboards?dataSource=prometheus&search=kubernetes

For more information on how to build your own dashboard check out: https://grafana.com/docs/guides/getting_started/

## Kube Monkey - Chaos

Clone [Microservices Observability and Chaos on Digital Ocean](https://github.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean.git)

```
cd
git clone https://github.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean.git
cd Microservices-Observability-and-Chaos-on-Digital-Ocean
```

Apply the mainifest files to install Kube Monkey.
```
k apply -f kube-monkey-rbac-socks-shop.yml
k apply -f kube-monkey-front-end.yml
k apply -f kube-monkey-cm-socks-shop.yml
k apply -f kube-monkey-deploy-socks-shop.yml
k get deployments -n sock-shop
```

To verify that everything is working as expected use this command: `k get deployments -n sock-shop`

Check for `kube-monkey` and check `front-end` is 4/4.
```
[jamesbuckett@surface ~ (digital-ocean-cluster:sock-shop)]$ k get deployments -n sock-shop
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
carts          1/1     1            1           22h
carts-db       1/1     1            1           22h
catalogue      1/1     1            1           22h
catalogue-db   1/1     1            1           22h
front-end      4/4     4            4           22h
kube-monkey    1/1     1            1           18h
orders         1/1     1            1           22h
orders-db      1/1     1            1           22h
payment        1/1     1            1           22h
queue-master   1/1     1            1           22h
rabbitmq       1/1     1            1           22h
shipping       1/1     1            1           22h
user           1/1     1            1           22h
user-db        1/1     1            1           22h
```

To verify that Kube Monkey is working: `k get pods -n sock-shop`

```
[jamesbuckett@surface ~ (digital-ocean-cluster:sock-shop)]$ k get pods -n sock-shop
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

## Locust - Performance 

Install [Locust](https://locust.io/)

`python -m pip install locustio`

Restart terminal for install to complete

Configure Locust: 
```
mkdir locust
cd locust
https://raw.githubusercontent.com/jamesbuckett/Microservices-Observability-and-Chaos-on-Digital-Ocean/master/locustfile-socks-shop.py
```

Obtain the external IP address of Socks Shop.
* `k -n sock-shop get svc front-end`
* The IP address under EXTERNAL-IPis the external IP address of Socks Shop.
* Use that address to stress the micro-services application.
* Start locust : `locust --host=http://<EXTERNAL-IP>`

Browse to : `http://127.0.0.1:8089/`
* Number of Users to Simulate: 500
* Hatch Rate: 10

On main panel select `Charts`
Top Right note Failures are 0%

From the terminal kill front-end pods to simulate chaos.

`k get pods -n sock-shop`

```
[jamesbuckett@surface ~ (digital-ocean-cluster:sock-shop)]$ k get pods -n sock-shop
NAME                            READY   STATUS    RESTARTS   AGE
carts-56c6fb966b-nrwx4          1/1     Running   0          23h
carts-db-5678cc578f-w99cf       1/1     Running   0          23h
catalogue-644549d46f-mpwrz      1/1     Running   0          23h
catalogue-db-6ddc796b66-rbp7h   1/1     Running   0          23h
front-end-6f9db4fd44-6mcw7      1/1     Running   0          20h
front-end-6f9db4fd44-7n228      1/1     Running   0          20h
front-end-6f9db4fd44-bn6t6      1/1     Running   0          20h
front-end-6f9db4fd44-lsm6z      1/1     Running   0          20h
kube-monkey-6b7c69cdd5-tt24h    1/1     Running   0          18h
orders-749cdc8c9-kqhsw          1/1     Running   0          23h
orders-db-5cfc68c4cf-pf7sq      1/1     Running   0          23h
payment-54f55b96b9-8x8z2        1/1     Running   0          23h
queue-master-6fff667867-fkxj6   1/1     Running   0          23h
rabbitmq-bdfd84d55-nx495        1/1     Running   0          23h
shipping-78794fdb4f-9fvfv       1/1     Running   0          23h
user-77cff48476-lk4rs           1/1     Running   0          23h
user-db-99685d75b-mzhqv         1/1     Running   0          23h
```

```
k delete front-end-6f9db4fd44-6mcw7 -n sock-shop
k delete front-end-6f9db4fd44-7n228 -n sock-shop
```

Observe in the Locust page that Failures are still 0%

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

#### Components
* the main Prometheus server which scrapes and stores time series data
* client libraries for instrumenting application code
* a push gateway for supporting short-lived jobs
* special-purpose exporters for services like HAProxy, StatsD, Graphite, etc.
* an alertmanager to handle alerts
* various support tools

Most Prometheus components are written in Go, making them easy to build and deploy as static binaries.

#### Architecture

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

## Tutorial Clean Up 

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

*End of Section*
