#!/bin/bash

set -e
 
if ! [ $UID -eq 0 ]; then
  echo "Building with a regular user is pretty slow."
  echo "Press enter to do it anyway."
  read
fi

tmp_dir=$(mktemp -d -t rocket-XXXXXXXXXX)
podman build -f Dockerfile.meteor -t rocket-builder:latest

#rm package-lock.json
podman run -it --rm -e METEOR_ALLOW_SUPERUSER=1 -v $(pwd):/root/code -v ${tmp_dir}:/root/out --workdir /root/code rocket-builder:latest bash -c "meteor npm install && meteor build --server-only --directory /root/out"

cp .docker/Dockerfile ${tmp_dir}

pushd ${tmp_dir}
podman build . -t rocket-chat:latest
popd

rm -rf ${tmp_dir}

if ! [ -z $SUDO_USER ]; then
  podman save rocket-chat:latest | sudo -u ${SUDO_USER} podman load
  podman image rm rocket-chat:latest
  chown -R ${SUDO_UID}:${SUDO_GID} .
fi
