#!/bin/bash

clear

printf "%s\n" "Starting clean up on Digital Ocean...."

doctl kubernetes cluster delete digital-ocean-cluster -f

printf "%s\n" "digital-ocean-cluster deleted"

doctl compute droplet delete digital-ocean-droplet -f

printf "%s\n" "digital-ocean-droplet deleted"

doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

printf "%s\n" "digital-ocean-loadbalancers deleted"

printf "%s\n" "Done with clean up on Digital Ocean...."