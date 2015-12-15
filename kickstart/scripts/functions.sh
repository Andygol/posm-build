#!/bin/bash

ks_fetch() {
  if [ -n "$KS" ]; then
    mkdir -p /root/`dirname "$1"`
    wget -q -O "/root/${1}" "$KS/${1}"
  fi
  if [ -n "$2" ]; then
    cp -p "/root/${1}" "$2"
    return $?
  fi
  test -e "/root/$1"
  return $?
}

expand() {
  ks_fetch "$1" && /usr/bin/interp < "/root/$1" > "$2"
}

from_github() {
  local url="$1"
  local dst="$2"
  local name="${url##*/}"
  mkdir -p "$dst"
  mkdir -p /root/sources
  wget -q -O "/root/sources/$name.tar.gz" "$url/archive/master.tar.gz"
  tar -zxf "/root/sources/$name.tar.gz" -C "$dst" --strip=1
  chown -R root:root "$dst"
  chmod -R o-w "$dst"
}

ubuntu_backport_install() {
  local pkg="$1"
  local src="$2"
  local workdir="${TMPDIR:-/tmp}/deb-$pkg"
  apt-get install -y \
    debhelper \
    devscripts \
    dh-autoreconf \
    dh-make \
    dh-make-perl \
    dh-python \
    dpkg-dev \
    ubuntu-dev-tools
  env DEBFULLNAME="James Flemer" DEBEMAIL="james.flemer@ndpgroup.com" UBUMAIL="james.flemer@ndpgroup.com" \
    backportpackage --update --dont-sign --workdir="$workdir" ${src:+--source=$src} "$pkg"
  tar -xf "$workdir/$pkg"*.orig.tar* -C "$workdir"
  tar -xf "$workdir/$pkg"*ubuntu*debian.tar*  -C "$workdir/$pkg"*/
  (cd "$workdir/$pkg"*/ && dpkg-buildpackage -b -nc -us -uc)
  dpkg -i "$workdir/$pkg"*.deb
}

deploy() {
  export DEBIAN_FRONTEND=noninteractive

  vendor=`lsb_release -si 2>/dev/null`
  if [ -z "$vendor" ]; then
    if [ -e /etc/redhat-release ]; then
      vendor=`awk '{print $1}' /etc/redhat-release`
    fi
  fi

  case $vendor in
    Ubuntu)
      fn="deploy_${1}_ubuntu"
      ;;
    CentOS|Red*)
      fn="deploy_${1}_rhel"
      ;;
    *)
      ;;
  esac
  if [ x"$(type -t $fn)" != x"function" ]; then
    fn="deploy_${1}"
  fi
  $fn
}
