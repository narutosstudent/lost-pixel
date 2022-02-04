#!/bin/sh


WORKSPACE=$PWD
STORYBOOK_PATH=${INPUT_STORYBOOK_PATH:-$STORYBOOK_PATH}
STORYBOOK_PATH=$WORKSPACE/${STORYBOOK_PATH:-storybook-static}

export CI_BUILD_ID=${GITHUB_RUN_ID:-$CI_BUILD_ID}
export CI_BUILD_NUMBER=${GITHUB_RUN_NUMBER:-$CI_BUILD_NUMBER}
export LOST_PIXEL_URL=${INPUT_LOST_PIXEL_URL:-$LOST_PIXEL_URL}
export LOST_PIXEL_PROJECT_ID=${INPUT_LOST_PIXEL_PROJECT_ID:-$LOST_PIXEL_PROJECT_ID}
export S3_END_POINT=${INPUT_S3_END_POINT:-$S3_END_POINT}
export S3_REGION=${INPUT_S3_REGION:-$S3_REGION}
export S3_ACCESS_KEY=${INPUT_S3_ACCESS_KEY:-$S3_ACCESS_KEY}
export S3_SECRET_KEY=${INPUT_S3_SECRET_KEY:-$S3_SECRET_KEY}
export S3_SESSION_TOKEN=${INPUT_S3_SESSION_TOKEN:-$S3_SESSION_TOKEN}
export S3_BUCKET_NAME=${INPUT_S3_BUCKET_NAME:-$S3_BUCKET_NAME}
export S3_BASE_URL=${INPUT_S3_BASE_URL:-$S3_BASE_URL}
IMAGE_PATH_BASE=${INPUT_IMAGE_PATH_BASE:-$IMAGE_PATH_BASE}
export IMAGE_PATH_BASE=$WORKSPACE/${IMAGE_PATH_BASE:-.}
export IMAGE_PATH_REFERENCE=${IMAGE_PATH_REFERENCE:-.loki/reference}
export IMAGE_PATH_CURRENT=${IMAGE_PATH_CURRENT:-.loki/current}
export IMAGE_PATH_DIFFERENCE=${IMAGE_PATH_DIFFERENCE:-.loki/difference}
export EVENT_PATH=${GITHUB_EVENT_PATH:-$EVENT_PATH}
export COMMIT_HASH=${GITHUB_SHA:-$COMMIT_HASH}
export COMMIT_REF=${GITHUB_REF:-$COMMIT_REF}
export COMMIT_REF_NAME=${GITHUB_REF_NAME:-$COMMIT_REF_NAME}
export REPOSITORY=${GITHUB_REPOSITORY:-$REPOSITORY}
CONCURRENCY=${INPUT_CONCURRENCY:-$CONCURRENCY}
export CONCURRENCY=${CONCURRENCY:-4}

echo "WORKSPACE=$WORKSPACE"
echo "STORYBOOK_PATH=$STORYBOOK_PATH"
echo "CI_BUILD_ID=$CI_BUILD_ID"
echo "CI_BUILD_NUMBER=$CI_BUILD_NUMBER"
echo "LOST_PIXEL_URL=$LOST_PIXEL_URL"
echo "LOST_PIXEL_PROJECT_ID=$LOST_PIXEL_PROJECT_ID"
echo "S3_END_POINT=$S3_END_POINT"
echo "S3_REGION=$S3_REGION"
echo "S3_ACCESS_KEY=$S3_ACCESS_KEY"
echo "S3_SECRET_KEY=$S3_SECRET_KEY"
echo "S3_SESSION_TOKEN=$S3_SESSION_TOKEN"
echo "S3_BUCKET_NAME=$S3_BUCKET_NAME"
echo "S3_BASE_URL=$S3_BASE_URL"
echo "IMAGE_PATH_BASE=$IMAGE_PATH_BASE"
echo "IMAGE_PATH_REFERENCE=$IMAGE_PATH_REFERENCE"
echo "IMAGE_PATH_CURRENT=$IMAGE_PATH_CURRENT"
echo "IMAGE_PATH_DIFFERENCE=$IMAGE_PATH_DIFFERENCE"
echo "EVENT_PATH=$EVENT_PATH"
echo "COMMIT_HASH=$COMMIT_HASH"
echo "COMMIT_REF=$COMMIT_REF"
echo "COMMIT_REF_NAME=$COMMIT_REF_NAME"
echo "REPOSITORY=$REPOSITORY"
echo "CONCURRENCY=$CONCURRENCY"


cd /app
mkdir -p $IMAGE_PATH_BASE/$IMAGE_PATH_REFERENCE
mkdir -p $IMAGE_PATH_BASE/$IMAGE_PATH_CURRENT
mkdir -p $IMAGE_PATH_BASE/$IMAGE_PATH_DIFFERENCE

./node_modules/.bin/loki \
--verboseRenderer \
--requireReference \
--reactUri file:$STORYBOOK_PATH \
--reference $IMAGE_PATH_BASE/$IMAGE_PATH_REFERENCE \
--output $IMAGE_PATH_BASE/$IMAGE_PATH_CURRENT \
--difference $IMAGE_PATH_BASE/$IMAGE_PATH_DIFFERENCE \
--chromeFlags="--headless --disable-gpu --hide-scrollbars --no-sandbox" \
--chromeConcurrency=$CONCURRENCY \
test

npm run start
