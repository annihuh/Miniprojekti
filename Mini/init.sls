#

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
    - unless: "ufw status | grep '22.*ALLOW.*Anywhere'"

ufw_deny_telnet:
  cmd.run:
    - name: "ufw deny 23"
    - unless: "ufw status | grep '23.*DENY.*Anywhere'"
    
ufw_allow_wireguard:
  cmd.run:
    - name: "ufw allow 51820"
    - unless: "ufw status | grep '51820.*ALLOW.*Anywhere'"

ufw_enable:
  cmd.run:
    - name: "sudo ufw enable"
    - unless: "sudo ufw status | grep -q 'Status: active'"

wireguard:
  pkg.installed:
    - name: wireguard

generate_private_key:
  file.managed:
    - name: "/etc/wireguard/private.key"
    - makedirs: True
    - mode: 0600
    - unless: "test -f /etc/wireguard/private.key"
  cmd.run:
    - name: "wg genkey | tee /etc/wireguard/private.key"

generate_public_key:
  file.managed:
    - name: "/etc/wireguard/public.key"
    - makedirs: True
    - unless: "test -f /etc/wireguard/public.key"
  cmd.run:
    - name: "cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key"
