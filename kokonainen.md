    vagrant up
    vagrant ssh [masterin nimi]
    sudo salt-key -A
    sudo apt-get update
    sudo apt-get install ufw
    sudo systemctl start ufw
    sudo systemctl status ufw.service
    sudo ufw allow openssh
    sudo ufw deny telnet
    sudo ufw enable
    sudo ufw status
    # Testaa yhteys
    ssh [nimi]@[ip-osoite]
    # Vaihtoehtoinen asennus ja testi
    sudo apt-get install telnet
      $ telnet 192.168.12.3
    sudo ufw allow 4505/tcp && sudo ufw allow 4506/tcp
    sudo ufw allow 51820
    sudo ufw reload tai enable
    
    sudo apt-get install wireguard
    wg genkey | sudo tee /etc/wireguard/private.key
    sudo chmod go= /etc/wireguard/private.key
    sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
    valitse osoitteet
    sudo micro /etc/wireguard/wg0.conf 
      [Interface]
      PrivateKey = 
      Address = 172.16.0.1/24
      ListenPort = 51820
      SaveConfig = true
    sudo systemctl enable wg-quick@wg0.service
    sudo systemctl start wg-quick@wg0.service
    sudo systemctl status wg-quick@wg0.service
    
    sudo mkdir -p /srv/salt/[kansion nimi]
    sudoedit /srv/salt/mini/init.sls löytyy täältä: https://github.com/annihuh/Miniprojekti/blob/main/Mini/init.sls
    sudoedit /srv/salt/projekti/init.sls löytyy täältä: https://github.com/annihuh/Miniprojekti/blob/main/Projekti/init.sls
    minioneilla: sudo wg ja katso public.key > kopioi masterille: sudo wg set wg0 peer [avain] allowed-ips [koneen ip-osoite]
    masterilla: sudo wg-quick up wg0 
    
    Jos epäselvyyksiä, katso raportti: https://github.com/annihuh/Miniprojekti/blob/main/Miniprojekti%20-%20h7.md tai tutstu lähteisiin.
