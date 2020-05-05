#!/bin/bash
# shellcheck disable=SC2154,SC2034
# this script contains:
## idempotent functions to define if LibreOffice Online has to be compiled
## Installation of requirements for Libreoffice Online build only
## Download & install LibreOffice Online Sources
set -e
SearchGitOpts=''
[ -n "${lool_src_branch}" ] && SearchGitOpts="${SearchGitOpts} -b ${lool_src_branch}"
[ -n "${lool_src_commit}" ] && SearchGitOpts="${SearchGitOpts} -c ${lool_src_commit}"
[ -n "${lool_src_tag}" ] && SearchGitOpts="${SearchGitOpts} -t ${lool_src_tag}"
#### Download dependencies ####
if [ -d ${lool_dir} ]; then
  cd ${lool_dir}
else
  git clone ${lool_src_repo} ${lool_dir}
  cd ${lool_dir}
fi
declare repChanged
eval "$(SearchGitCommit $SearchGitOpts)"
if [ -f ${lool_dir}/loolwsd ] && $repChanged ; then
  lool_forcebuild=true
fi
if [ "${DIST}" = "Debian" ]; then
  if [ "${CODENAME}" = "buster" ];then
    apt-get install  node-gyp libssl-dev npm libpococrypto60 -y
  else 
    apt-get install nodejs-dev node-gyp libssl1.0-dev npm libpococrypto50 -y
  fi
else
  apt-get install nodejs-dev node-gyp libssl1.0-dev npm libpococrypto50 -y
fi

set +e
if ! npm -g list jake >/dev/null; then
  npm install -g npm
  npm install -g jake
fi

sed  '16a\
#include <list>
' < ${lool_dir}/wsd/AdminModel.hpp > ${lool_dir}/wsd/AdminModeltmp.hpp 
cat ${lool_dir}/wsd/AdminModeltmp.hpp > ${lool_dir}/wsd/AdminModel.hpp
