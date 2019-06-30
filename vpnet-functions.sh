#!/usr/bin/env bash
#
# VPNet - Virtual Private Network Essential Toolbox
#
# https://github.com/acrossfw/vpnet
#

vpnet::init_bash() {
  #
  # Bash3 Boilerplate. Copyright (c) 2014, kvz.io
  # http://kvz.io/blog/2013/11/21/bash-best-practices/
  #
  set -o errexit
  set -o pipefail
  set -o nounset
  # set -o xtrace

  local source=$1
  if [[ -z "$source" ]]; then
    echo "ERROR: vpnet::init_bash must have BASH_SOURCE[0] as arg1"
    return 1
  fi

  # Set magic variables for current file & dir
  declare -gx __dir
  declare -gx __file
  declare -gx __base
  declare -gx __root

  __dir="$(cd "$(dirname "$source}")" && pwd)"
  __file="${__dir}/$(basename "${source}")"
  __base="$(basename "${__file}" .sh)"
  __root="${ACROSSFW_HOME:-/acrossfw}" # "$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app
}

vpnet::init_env_var() {
  if vpnet::is_docker ; then
    # shellcheck disable=SC1090
    source "$ACROSSFW_HOME/ENV.build"

    [[ -f "$ACROSSFW_HOME/ENV.config" ]] && {
      # shellcheck disable=SC1090
      source "$ACROSSFW_HOME/ENV.config"
    }
  fi

  declare -gx WANIP
  WANIP=$(curl -Ss ifconfig.io)

  vpnet::init_host_id
}

vpnet::init_host_id() {
  local id
  id=$(ip addr show eth1 | grep ether | awk '{print $2}' | awk -F: '{print $5$6}')
  HOSTNAME=${HOSTNAME/vpnet./vpnet-$id.}
}

vpnet::check_env() {
  [[ "$(id -u)" = 0 ]] || {
    echo "ERROR: must run as root"
    return 1
  }

  [[ "${ACROSSFW_HOME}" ]] || {
    echo "ERROR: ACROSSFW_HOME environment variable not defined"
    return 1
  }

  return 0
}

vpnet::init_config() {
  config_file=$1
  [[ "$config_file" =~ ^/ ]] || {
    vpnet::log "ERROR: vpnet::init_config need absolute filename start with '/'"
    return 1
  }

  #
  # $__dir is the magic variable set by init_bash
  # standard for the script execute dir
  #
  template_file="${__dir}/root${config_file}"
  [ -f "$template_file" ] || {
    vpnet::log "ERROR: vpnet::init_config cant find '$template_file'! must run in 'service/SRV/run'"
    return 1
  }

  vpnet::is_docker || {
    vpnet::log "ERROR: vpnet::init_config can only run inside docker(or it will overwrite root filesystem)"
    exit 1
  }

  echo "vpnet::init_config initing $config_file from $template_file ..."
  # Templating with Linux in a Shell Script
  # http://serverfault.com/a/699377/276381
  template="$(cat "${template_file}")"
  eval "echo \"${template}\"" > "$config_file"
}

vpnet::is_docker() {
  # XXX simulate docker for test
  # return 0

  # http://stackoverflow.com/a/20012536/1123955
  if [[ $(sort -n /proc/1/cgroup | head -1) =~ /$ ]]; then
    # end with '/', should be the host
    return 1
  else
    # end with container string, should insdie docker
    return 0
  fi
}

#
# System & Networking Initialization
#
vpnet::init_system() {
  echo "Setting hostname to $HOSTNAME ..."
  # XXX: this will not work in --net=host mode
  # https://github.com/docker/docker/issues/5708
  hostname "$HOSTNAME" || echo "WARN: set hostname fail"

  echo "Disabling coredump ..."
  sysctl fs.suid_dumpable=0
  ulimit -S -c 0
  echo "* hard core 0" >> /etc/security/limits.conf
}

vpnet::init_network() {
  echo "Setting ip forwarding to 1 ..."
  sysctl -w net.ipv4.ip_forward=1           || echo "WARN: sysctl ip_forward fail"
  sysctl -w net.ipv4.conf.all.forwarding=1  || echo "WARN: sysctl ipv4 forwarding fail"
  sysctl -w net.ipv6.conf.all.forwarding=1  || echo "WARN: sysctl ipv6 forwarding fail"
  sysctl -w net.ipv6.conf.all.proxy_ndp=1   || echo "WARN: sysctl proxy_ndp fail"
  echo 1 > /proc/sys/net/ipv4/route/flush   || echo "WARN: sysctl ipv4 flush fail"

  echo "Enabling Google BBR for TCP ..."
  sysctl -w net.core.default_qdisc=fq           || echo "WARN: sysctl default_qdisc fail"
  sysctl -w net.ipv4.tcp_congestion_control=bbr || echo "WARN: sysctl tcp_congestion_control fail"

  # XXX does there always be `eth1` in docker ???
  echo "Setting network filter ..."
  iptables -t nat -A POSTROUTING -s 10.0.0.0/8      -o eth1 -j MASQUERADE || echo "WARN: iptables fail"
  iptables -t nat -A POSTROUTING -s 172.16.0.0/12   -o eth1 -j MASQUERADE || echo "WARN: iptables fail"
  iptables -t nat -A POSTROUTING -s 192.168.0.0/16  -o eth1 -j MASQUERADE || echo "WARN: iptables fail"

  # ip6tables -t nat -A POSTROUTING -s 2a00:1450:400c:c05::/64 -o eth1 -j MASQUERADE

  # XXX no need ? iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
}

vpnet::get_user_home() {
  local user_name=${1:-''}
  local __resultvar=${2:-''}

  case $__resultvar in
    '__resultvar'|'__user_home'|'user_name'|'error_code')
      vpnet::log "ERROR: vpnet::get_user_home __user_home is reserved by this function"
      return 1
      ;;
  esac

  local __user_home
  local error_code

  __user_home=$(eval echo ~"$user_name")
  error_code=0

  # non-exist user will not resolve and keep the origin string, which has a leading '~'
  [[ "$__user_home" =~ ^~ ]] && {
    vpnet::log "ERROR: vpnet::get_user_home can not find home for user: %s" "$user_name"
    error_code=1 # no such user
  }

  case "${#@}" in
    1)
      echo "$__user_home"
      ;;
    2)
      vpnet::set_var_value "$__resultvar" "$__user_home"
      ;;
    *)
      vpnet::log "ERROR: vpnet::get_user_home should take 1 or 2 args"
      error_code=1
      ;;
  esac

  return "$error_code"
}

# http://www.linuxjournal.com/content/return-values-bash-functions
vpnet::set_var_value() {
  local __resultvar=$1
  local __value=$2

  if [[ "$__resultvar" = "__resultvar" || "$__resultvar" = "__value" ]]; then
    vpnet::log "ERROR: vpnet::set_var_value reserved name: __resultvar & __value"
    return 1
  fi
  # declare global variable http://stackoverflow.com/q/9871458/1123955
  eval "$__resultvar='$__value'"
}

vpnet::log() {
  eval "printf $*" >&2
  echo >&2
}
