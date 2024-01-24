#!/bin/bash

scaling(){
    # Get all ECS cluster arn
    clusters=$(aws ecs list-clusters --query "clusterArns" --output text)
    
    # Iterate all clusters arn one by one
    for cluster in $clusters; do

        #Fetch the cluster name by cluster arn
        cluster_name=$(aws ecs describe-clusters --clusters $cluster --query "clusters[0].clusterName" --output text)
        
        #print the cluster name
        echo "Cluster Name: $cluster_name"

        #fetch cluster tags
        cluster_tags=$(aws ecs list-tags-for-resource --resource-arn $cluster --query "tags")

        #apply filter on the tags for the required key pair value
        filtered_tags=$(aws ecs list-tags-for-resource --resource-arn $cluster --query "tags[?key=='ENV' && value=='demo']" --output text)
        echo "$filtered_tags"

        variableLength=${#filtered_tags}
       if [ $variableLength -gt 1 ]; then
            #fetch the service arn of the cluter
            services=$(aws ecs list-services --cluster $cluster --query "serviceArns" --output text)
            #check the cluster have service or not
            if [ -n "$services" ]; then
                # Iterate all service arn one by one
                for service in $services; do
                    # fetch the service name by service arn
                    service_name=$(aws ecs describe-services --cluster $cluster --services $service --query "services[0].serviceName" --output text)
                    #aws cli command to upscale the cluster
                    aws ecs update-service --cluster $cluster_name --service $service_name --desired-count $DESIRED_COUNT > /dev/null
                    aws ecs wait services-stable --cluster $cluster_name --services $service_name > /dev/null
                    echo "  - $service_name"
                done
            else
                echo "No services found in the cluster."
            fi

        else
            echo "The variable is either empty or has a length of 0."
        fi
    done
}

# Usage
if [ "$1" == "upscale" ]; then
    DESIRED_COUNT=1
    scaling
elif [ "$1" == "downscale" ]; then
    DESIRED_COUNT=0
    scaling
else
  echo "Usage: $0 {upscale|downscale}"
  exit 1
fi