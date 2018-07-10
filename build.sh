#!/bin/bash
mkdir tmp
cp Dockerfile tmp/
pushd tmp

# Run once on host
# docker run --rm --privileged multiarch/qemu-user-static:register

TARGETS="aarch64 x86_64" #  arm

for arch in $TARGETS; do
  if [ ! -f "qemu-"$arch"-static" ]; then
    wget -N https://github.com/multiarch/qemu-user-static/releases/download/v2.9.1-1/x86_64_qemu-${arch}-static.tar.gz
    tar -xvf x86_64_qemu-${arch}-static.tar.gz
    rm x86_64_qemu-${arch}-static.tar.gz
  fi
done

for arch in $TARGETS; do
  case ${arch} in
    x86_64)   base_arch="amd64" ;;
    arm)      base_arch="arm32v6" ;;
    aarch64)  base_arch="arm64v8" ;;    
  esac
  echo Building $arch $base_arch
	docker build -t ags131/toolbox:latest-$arch --build-arg TARGET_ARCH=$arch --build-arg BASE_ARCH=$base_arch --build-arg USER=adam .
  docker push ags131/toolbox:latest-$arch
done

echo Creating manifest
docker manifest create --amend ags131/toolbox:latest ags131/toolbox:latest-x86_64 ags131/toolbox:latest-aarch64 # ags131/toolbox:latest-arm
docker manifest annotate ags131/toolbox:latest ags131/toolbox:latest-x86_64 --os linux --arch amd64
# docker manifest annotate ags131/toolbox:latest ags131/toolbox:latest-arm --os linux --arch arm
docker manifest annotate ags131/toolbox:latest ags131/toolbox:latest-aarch64 --os linux --arch arm64
docker manifest push ags131/toolbox:latest -p

popd
rm -rf tmp