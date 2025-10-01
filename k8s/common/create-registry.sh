#!/bin/bash


# Harbor Registry용 Secret 생성
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=amdp-registry.skala-ai.com \
  --docker-username="robot\$skala25a" \
  --docker-password="1qB9cyusbNComZPHAdjNIFWinf52xaBJ" \
  --docker-email="skala@gmail.com" \
  -n skala-practice
