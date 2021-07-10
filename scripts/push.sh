#!/usr/bin/env bash
set -x

# Available environment variables
#
# DOCKER_REGISTRY
# OPENSTACK_VERSION
# REPOSITORY
# VERSION

# Set default values

DOCKER_REGISTRY=${DOCKER_REGISTRY:-quay.io}
OPENSTACK_VERSION=${OPENSTACK_VERSION:-master}
REPOSITORY=${REPOSITORY:-osism/kolla-ansible}
VERSION=${VERSION:-latest}

COMMIT=$(git rev-parse --short HEAD)

# NOTE: For builds for a specific release, the OpenStack version is taken from the release repository.
if [[ $VERSION != "latest" ]]; then
    filename=$(curl -L https://raw.githubusercontent.com/osism/release/master/$VERSION/openstack.yml)
    OPENSTACK_VERSION=$(curl -L https://raw.githubusercontent.com/osism/release/master/$VERSION/$filename | grep "openstack_version:" | awk -F': ' '{ print $2 }')
fi

. defaults/$OPENSTACK_VERSION.sh

if [[ -n $DOCKER_REGISTRY ]]; then
    REPOSITORY="$DOCKER_REGISTRY/$REPOSITORY"
fi

if [[ $OPENSTACK_VERSION == "master" ]]; then
    tag=$REPOSITORY:latest

    docker tag "$tag-$COMMIT" "$tag"
    docker push "$tag"
else
    tag=$REPOSITORY:$OPENSTACK_VERSION

    docker tag "$tag-$COMMIT" "$tag-$VERSION"
    docker push "$tag-$VERSION"

    docker tag "$tag-$COMMIT" "$tag"
    docker push "$tag"
fi
