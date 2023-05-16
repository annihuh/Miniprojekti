# Luo määritellyille koneille wg0.conf-tiedoston ja lisää sisällön.

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
{% set private_key = salt['file.read']('/etc/wireguard/private.key') %}

wg0_config_a002:
  file.managed:
    - name: "/etc/wireguard/wg0.conf"
    - makedirs: True
    - contents: |
        [Interface]
        PrivateKey = {{ private_key }}
        Address = 172.16.0.101/24
        ListenPort = 51820

        [Peer]
        PublicKey = S0RuAg+2cJz4dXp6f3W1GQQ1xsOK9lHnEuE8YsGtdDk=        
        AllowedIPs = 172.16.0.0/24
        Endpoint = 192.168.12.3:51820
        PersistentKeepalive = 25

{% endif %}
