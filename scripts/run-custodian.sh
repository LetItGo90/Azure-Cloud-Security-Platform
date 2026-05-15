#!/bin/bash
set -e

OUTPUT_DIR="cspm/cloud-custodian/output/dry-run"
POLICY_DIR="custodian/policies"

mkdir -p $OUTPUT_DIR

echo "Running Cloud Custodian policies..."

for policy in $POLICY_DIR/keyvault-compliance.yml \
              $POLICY_DIR/network-compliance.yml \
              $POLICY_DIR/storage-compliance.yml \
              $POLICY_DIR/tagging-compliance.yml \
              $POLICY_DIR/vm-compliance.yml; do

  echo "Running: $policy"
  custodian run \
    --output-dir $OUTPUT_DIR \
    --cache-period 0 \
    $policy || echo "Warning: $policy failed, continuing..."

done

echo "All policies complete. Results in $OUTPUT_DIR"