#!/bin/sh

kubectl delete deployments.apps hacbs-jvm-operator -n jvm-build-service
# we don't restart the cache and local storage by default
# for most cases in development this is not necessary, and just slows things
# down by needing things to be re-cached/rebuilt
#kubectl delete deployments.apps hacbs-jvm-cache -n jvm-build-service
#kubectl delete deployments.apps localstack -n jvm-build-service

DIR=`dirname $0`
$DIR/install-openshift-pipelines.sh
kubectl apply -f $DIR/namespace.yaml
kubectl config set-context --current --namespace=test-jvm-namespace
JVM_BUILD_SERVICE_IMAGE=quay.io/$QUAY_USERNAME/hacbs-jvm-controller \
JVM_BUILD_SERVICE_CACHE_IMAGE=quay.io/$QUAY_USERNAME/hacbs-jvm-cache \
JVM_BUILD_SERVICE_SIDECAR_IMAGE=quay.io/$QUAY_USERNAME/hacbs-jvm-sidecar:dev \
JVM_BUILD_SERVICE_REQPROCESSOR_IMAGE=quay.io/$QUAY_USERNAME/hacbs-jvm-build-request-processor:dev \
JVM_BUILD_SERVICE_ANALYZER_IMAGE=quay.io/$QUAY_USERNAME/hacbs-jvm-dependency-analyser:dev \
JVM_BUILD_SERVICE_JDK8_BUILDER_IMAGE=quay.io/$QUAY_USERNAME/hacbs-jdk8-builder:dev \
JVM_BUILD_SERVICE_JDK11_BUILDER_IMAGE=quay.io/$QUAY_USERNAME/hacbs-jdk11-builder:dev \
JVM_BUILD_SERVICE_JDK17_BUILDER_IMAGE=quay.io/$QUAY_USERNAME/hacbs-jdk17-builder:dev \
$DIR/patch-yaml.sh

#TODO: we still need to deal with this in infra deployments for the tests
#so this is not aligned yet
find $DIR -path \*development\*.yaml -exec sed -i s/QUAY_TOKEN/${QUAY_TOKEN}/ {} \;
