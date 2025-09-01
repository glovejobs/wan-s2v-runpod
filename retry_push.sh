#!/bin/bash

# Retry Docker push script for large images
IMAGE_NAME="glovejobs/wan2v-s2v-14b:latest"
MAX_RETRIES=5
RETRY_COUNT=0

echo "🚀 Starting Docker push with retry mechanism..."
echo "Image: $IMAGE_NAME"
echo "Max retries: $MAX_RETRIES"
echo ""

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Attempt $(($RETRY_COUNT + 1)) of $MAX_RETRIES..."
    
    if docker push $IMAGE_NAME; then
        echo "✅ Push completed successfully!"
        exit 0
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "❌ Push failed. Waiting 30 seconds before retry..."
            sleep 30
        fi
    fi
done

echo "❌ Push failed after $MAX_RETRIES attempts"
echo "You may want to:"
echo "1. Check your internet connection"
echo "2. Try pushing during off-peak hours"
echo "3. Consider using 'docker push --disable-content-trust $IMAGE_NAME'"
exit 1
