# chmod +x single_cluster_autoscale.sh
# ./single_cluster_autoscale.sh

#!/bin/bash
ECS_CLUSTER_NAME="scaling-cluster1" #cluter name specified
ECS_SERVICE_NAME="scaling-service" #service name specified which is present in the above mentioned cluster

UPSCALE_DESIRED_COUNT=1
DOWNSCALE_DESIRED_COUNT=0

#function for upscaling the single service
upscale() {
  aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --desired-count $UPSCALE_DESIRED_COUNT
  echo "Service upscaled to $UPSCALE_DESIRED_COUNT tasks."
}

#function for downscaling the single service
downscale() {
  aws ecs update-service --cluster $ECS_CLUSTER_NAME --service $ECS_SERVICE_NAME --desired-count $DOWNSCALE_DESIRED_COUNT
  echo "Service downscaled to $DOWNSCALE_DESIRED_COUNT tasks."
}

#with user input
if [ "$1" == "upscale" ]; then
  upscale
elif [ "$1" == "downscale" ]; then
  downscale
else
  echo "Usage: $0 {upscale|downscale}"
  exit 1
fi