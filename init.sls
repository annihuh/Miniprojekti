ufw:
  pkg.installed:
    - name: ufw

openssh:
  pkg.installed:
    - names:
      - openssh-server
      - openssh-client
  service.running:
    - name: sshd
    - enable: True

ufw_allow_ssh:
  cmd.run:
    - name: "ufw allow 22"

ufw_deny_telnet:
  cmd.run:
    - name: "ufw deny 23"

ufw_allow_wireguard:
  cmd.run:
    - name: "ufw allow 51820"

ufw_enable:
  service.running:
    - name: ufw
    - enable: True
    
wireguard:
  pkg.installed:
    - name: wireguard

generate_private_key:
  cmd.run:
    - name: "wg genkey | tee /etc/wireguard/private.key"
    - makedirs: True
    - unless: "test -f /etc/wireguard/private.key"

change_mode:
  file.managed:
    - name: "/etc/wireguard/private.key"
    - mode: 0600

generate_public_key:
  cmd.run:
    - name: "cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key"
    - makedirs: True
    - unless: "test -f /etc/wireguard/public.key"

{% if grains.get('id') == 'a001' %}

wg0_config_a001:
  file.managed:
    - name: "/etc/wireguard/wg0.conf"
    - makedirs: True
    - contents: |
        [Interface]
        PrivateKey = {{ salt['file.read']('/etc/wireguard/private.key') }}
        Address = 172.16.0.100/24
        ListenPort = 51820

        [Peer]
        PublicKey = S0RuAg+2cJz4dXp6f3W1GQQ1xsOK9lHnEuE8YsGtdDk=
        AllowedIPs = 172.16.0.0/24
        Endpoint = 192.168.12.3:51820
        PersistentKeepalive = 25

{% endif %}

{% if grains.get('id') == 'a002' %}

wg0_config_a002:
  file.managed:
    - name: "/etc/wireguard/wg0.conf"
    - makedirs: True
    - contents: |
        [Interface]
        PrivateKey = {{ salt['file.read']('/etc/wireguard/private.key') }}
        Address = 172.16.0.101/24
        ListenPort = 51820

        [Peer]
        PublicKey = S0RuAg+2cJz4dXp6f3W1GQQ1xsOK9lHnEuE8YsGtdDk=
        AllowedIPs = 172.16.0.0/24
        Endpoint = 192.168.12.3:51820
        PersistentKeepalive = 25

{% endif %}

open_tunnel:
  cmd.run:
    - name: |
        sudo wg-quick down wg0
        sudo wg-quick up wg0
    - watch:
      - file: "/etc/wireguard/wg0.conf"
