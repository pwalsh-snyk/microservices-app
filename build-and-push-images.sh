#!/bin/bash

# ECR base URI
ECR_URI="730335571577.dkr.ecr.us-west-2.amazonaws.com/online-boutique"
AWS_REGION="us-west-2"

# List of images and their contexts
IMAGES=(
    "emailservice:src/emailservice"
    "productcatalogservice:src/productcatalogservice"
    "recommendationservice:src/recommendationservice"
    "shoppingassistantservice:src/shoppingassistantservice"
    "shippingservice:src/shippingservice"
    "checkoutservice:src/checkoutservice"
    "paymentservice:src/paymentservice"
    "currencyservice:src/currencyservice"
    "cartservice:src/cartservice/src"
    "frontend:src/frontend"
    "adservice:src/adservice"
    "loadgenerator:src/loadgenerator"
)

# Ensure the main repository exists
echo "Ensuring main repository exists: online-boutique"
aws ecr describe-repositories --repository-name online-boutique --region $AWS_REGION >/dev/null 2>&1 || \
aws ecr create-repository --repository-name online-boutique --region $AWS_REGION

# Loop through images, check existence, build, and push
for IMAGE_CONTEXT in "${IMAGES[@]}"; do
    IMAGE=$(echo "$IMAGE_CONTEXT" | cut -d: -f1)
    CONTEXT=$(echo "$IMAGE_CONTEXT" | cut -d: -f2)

    # Check if the image already exists in ECR
    echo "Checking if $IMAGE already exists in ECR..."
    aws ecr describe-images --repository-name online-boutique --image-ids imageTag=$IMAGE --region $AWS_REGION >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$IMAGE already exists in ECR. Skipping..."
        continue
    fi

    # Build the image
    echo "Building $IMAGE from context $CONTEXT"
    docker build -t $ECR_URI:$IMAGE $CONTEXT || { echo "Failed to build $IMAGE"; exit 1; }

    # Push the image to ECR
    echo "Pushing $IMAGE to ECR..."
    docker push $ECR_URI:$IMAGE || { echo "Failed to push $IMAGE"; exit 1; }
done

echo "All missing images built and pushed successfully to $ECR_URI!"

