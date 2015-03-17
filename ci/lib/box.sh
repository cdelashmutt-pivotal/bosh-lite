#!/bin/bash

box_version() {
  echo ${BOSH_LITE_CANDIDATE_BUILD_NUMBER:-`cat /tmp/build/src/box-version/number`}
}

check_pipeline_bucket() {
  if [ -z "$PIPELINE_BUCKET" ]; then
    echo "PIPELINE_BUCKET needs to be set"
    exit 1
  fi
}

download_box() {
  box_type=$1
  box_version=$2

  check_pipeline_bucket

  box_name=bosh-lite-${box_type}-ubuntu-trusty-${box_version}.box
  rm -f $box_name
  wget "https://s3.amazonaws.com/${PIPELINE_BUCKET}/${box_name}"
}

upload_box() {
  box_type=$1
  box_version=$2

  check_pipeline_bucket

  box_name=bosh-lite-${box_type}-ubuntu-trusty-${box_version}.box
  s3cmd \
    --access_key=$BOSH_AWS_ACCESS_KEY_ID \
    --secret_key=$BOSH_AWS_SECRET_ACCESS_KEY \
    put $box_name s3://${PIPELINE_BUCKET}/
}

promote_box() {
  box_type=$1
  box_version=$2

  check_pipeline_bucket

  if [ -z "$FINAL_BOXES_BUCKET" ]; then
    echo "FINAL_BOXES_BUCKET needs to be set"
    exit 1
  fi

  box_name=bosh-lite-${box_type}-ubuntu-trusty-${box_version}.box
  s3cmd \
    --access_key=$BOSH_AWS_ACCESS_KEY_ID \
    --secret_key=$BOSH_AWS_SECRET_ACCESS_KEY \
    mv s3://${PIPELINE_BUCKET}/$box_name s3://${FINAL_BOXES_BUCKET}/$box_name
}
