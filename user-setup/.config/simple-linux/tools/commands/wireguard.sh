#!/bin/bash
#WIP IGNORE THIS SCRIPT
#
. "${TOOLSET_SCRIPT_DIR}/global.sh"

usage() { echo "Usage: $SCRIPT_NAME [setup-remote|setup-local]"; }

setup_wireguard_remote() {
  local wireguard_interface="$1" wireguard_ip_base="$2" server_ip="$3" server_port="$4" server_user="$5" server_key="$6" client_ip="$7" client_user="$8" client_key="$9"
 
  info "Veryfying connections"
  ssh $server_user@$server_ip -i $server_key "echo server_hello"
  ssh $client_user@$client_ip -i $client_key "echo client_hello"

  local server_private_ip="10.${wireguard_ip_base}.0.1/24"
  local client_private_ip="10.${wireguard_ip_base}.0.2/24"
  local server_allowed_ip="10.${wireguard_ip_base}.0.1/32"
  local client_allowed_ip="10.${wireguard_ip_base}.0.2/32"

  local server_publiclient_key_path="/etc/wireguard/${wireguard_interface}_server_publickey"
  local client_publiclient_key_path="/etc/wireguard/${wireguard_interface}_client_publickey"
  local server_private_key_path="/etc/wireguard/${wireguard_interface}_server_privatekey"
  local client_private_key_path="/etc/wireguard/${wireguard_interface}_client_privatekey"
  local interface_path="/etc/wireguard/${wireguard_interface}.conf"

  info "Creating wireguard keys..."
  ssh $server_user@$server_ip -i $server_key "sudo sh -c 'umask 077; wg genkey | tee $server_private_key_path | wg pubkey > $server_publiclient_key_path'"
  ssh -t $client_user@$client_ip -i $client_key "sudo sh -c 'umask 077; wg genkey | tee $client_private_key_path | wg pubkey > $client_publiclient_key_path'"

  local server_publiclient_key=$(ssh $server_user@$server_ip -i $server_key "sudo cat $server_publiclient_key_path")
  local client_publiclient_key=$(ssh $client_user@$client_ip -i $client_key "sudo cat $client_publiclient_key_path")

  info "Setting up wireguard..."
  ssh $server_user@$server_ip -i $server_key "sudo bash -c 'cat > $interface_path'" <<EOF
[Interface]
Address = $server_private_ip
ListenPort = $server_port
PrivateKey = $(ssh $server_user@$server_ip -i $server_key "sudo cat $server_private_key_path")
[Peer]
PublicKey = $client_publiclient_key
AllowedIPs = $client_allowed_ip
EOF
  ssh $client_user@$client_ip -i $client_key "sudo bash -c 'cat > $interface_path'" <<EOF
[Interface]
Address = $client_private_ip
PrivateKey = $(ssh $client_user@$client_ip -i $client_key "sudo cat $client_private_key_path")
[Peer]
PublicKey = $server_publiclient_key
AllowedIPs = $server_allowed_ip
Endpoint = $server_ip:$server_port
PersistentKeepalive = 15
EOF

  ssh $server_user@$server_ip -i $server_key "sudo wg-quick down $wireguard_interface || true; sudo wg-quick up $wireguard_interface"
  ssh $client_user@$client_ip -i $client_key "sudo wg-quick down $wireguard_interface || true; sudo wg-quick up $wireguard_interface"
}

setup_wireguard_local() {
  local wireguard_interface="$1" wireguard_ip_base="$2" server_ip="$3" server_port="$4" server_user="$5" server_key="$6"
  
  local server_private_ip="10.${wireguard_ip_base}.0.1/24"
  local client_private_ip="10.${wireguard_ip_base}.0.2/24"
  local server_allowed_ip="10.${wireguard_ip_base}.0.1/32"
  local client_allowed_ip="10.${wireguard_ip_base}.0.2/32"

  local server_publiclient_key_path="/etc/wireguard/${wireguard_interface}_server_publickey"
  local client_publiclient_key_path="/etc/wireguard/${wireguard_interface}_client_publickey"
  local server_private_key_path="/etc/wireguard/${wireguard_interface}_server_privatekey"
  local client_private_key_path="/etc/wireguard/${wireguard_interface}_client_privatekey"
  local interface_path="/etc/wireguard/${wireguard_interface}.conf"

  info "Creating wireguard keys..."
  ssh $server_user@$server_ip -i $server_key "sudo sh -c 'umask 077; wg genkey | tee $server_private_key_path | wg pubkey > $server_publiclient_key_path'"
  sudo sh -c "umask 077; wg genkey | tee $client_private_key_path | wg pubkey > $client_publiclient_key_path"
  
  local server_publiclient_key=$(ssh $server_user@$server_ip -i $server_key "sudo cat $server_publiclient_key_path")
  local client_publiclient_key=$(sudo cat $client_publiclient_key_path)
  local client_private_key=$(sudo cat $client_private_key_path)
  
  info "Setting up wireguard..."
  ssh $server_user@$server_ip -i $server_key "sudo bash -c 'cat > $interface_path'" <<EOF
[Interface]
Address = $server_private_ip
ListenPort = $server_port
PrivateKey = $(ssh $server_user@$server_ip -i $server_key "sudo cat $server_private_key_path")
[Peer]
PublicKey = $client_publiclient_key
AllowedIPs = $client_allowed_ip
EOF
  sudo tee $interface_path > /dev/null <<EOF
[Interface]
Address = $client_private_ip
PrivateKey = $client_private_key
[Peer]
PublicKey = $server_publiclient_key
AllowedIPs = $server_allowed_ip
Endpoint = $server_ip:$server_port
PersistentKeepalive = 15
EOF
  ssh $server_user@$server_ip -i $server_key "sudo wg-quick down $wireguard_interface 2>/dev/null; sudo wg-quick up $wireguard_interface"
  sudo wg-quick down $wireguard_interface || true
  sudo wg-quick up $wireguard_interface
}


handle_action() {
  local action="$1"; shift

  case "$action" in
    setup-remote)
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --wireguard-interface) wireguard_interface="$2"; shift 2 ;;
          --wireguard-ip-base)   wireguard_ip_base="$2"; shift 2 ;;
          --server-ip)           server_ip="$2"; shift 2 ;;
          --server-port)         server_port="$2"; shift 2 ;;
          --server-user)         server_user="$2"; shift 2 ;;
          --server-key)          server_key="$2"; shift 2 ;;
          --client-ip)           client_ip="$2"; shift 2 ;;
          --client-user)         client_user="$2"; shift 2 ;;
          --client-key)          client_key="$2"; shift 2 ;;
          *) echo "Unknown param: $1"; usage; exit 1 ;;
        esac
      done
      for var in wireguard_interface wireguard_ip_base server_ip server_port server_user server_key client_ip client_user client_key; do
        [ -z "${!var}" ] && echo "Missing required param: --$var" && usage && exit 1
      done
      setup_wireguard_remote "$wireguard_interface" "$wireguard_ip_base" "$server_ip" "$server_port" "$server_user" "$server_key" "$client_ip" "$client_user" "$client_key"
      ;;
    setup-local)
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --wireguard-interface) wireguard_interface="$2"; shift 2 ;;
          --wireguard-ip-base)   wireguard_ip_base="$2"; shift 2 ;;
          --server-ip)           server_ip="$2"; shift 2 ;;
          --server-port)         server_port="$2"; shift 2 ;;
          --server-user)         server_user="$2"; shift 2 ;;
          --server-key)          server_key="$2"; shift 2 ;;
          *) echo "Unknown param: $1"; usage; exit 1 ;;
        esac
      done
      for var in wireguard_interface wireguard_ip_base server_ip server_port server_user server_key; do
        [ -z "${!var}" ] && echo "Missing required param: --$var" && usage && exit 1
      done
      setup_wireguard_local "$wireguard_interface" "$wireguard_ip_base" "$server_ip" "$server_port" "$server_user" "$server_key"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
case "$1" in
  setup-remote|setup-local)
    handle_action "$@"
    ;;
  *)
    usage
    exit 1
    ;;
esac
