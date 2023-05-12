# h7 - Miniprojekti

Valmiustaso: Valmis

Projektin tarkoitus on tutustua perustasolla UFW:n ja VPN:n konfiguroimiseen manuaalisesti ja automatisoiden Saltilla.

[Linkki UFW:n automatisointiin](#ufwn-automatisointi)
[Linkki WireGuardin automatisointiin](#wireguard-vpn-käsin)


## Rauta

    Hostkone: Windows 11 Home
    CPU: Intel(R) Core(TM) i3-8130U CPU @ 2.20GHz   2.21 GHz
    Järjestelmätyyppi: x64-suoritin
    Linux: Debian GNU/Linux 11 (bullseye)

## UFW käsin

Projektissani asennan UFW:n eli Uncomplicated Firewallin isäntä-orja-arkkitehtuuria käyttäville koneille salttia käyttäen. Aloitin asentamisen sillä, että käytin kurssin alussa annettua Vagrantfile-tiedostoa, joka määrittelee isännän ja orjien tietoja. Muutin hieman koneiden nimiä: `t001 > a001` ja käynnistin ne komennolla `vagrant up`. Kirjauduin amaster koneelle `vagrant ssh amaster`. Ajoin komennon `sudo salt-key -A` ja hyväksyin avaimet a001 ja a002. Nyt ympäristö on valmis käytettäväksi.

Jatkoin UFW:n asentamiseen amasterilla. Varmistin, että kaikki on päivitetty ajamalla komennon `sudo apt-get update`. Sen jälkeen asensin, käynnistin ja katsoin onko UFW päällä.

    sudo apt-get install ufw
    sudo systemctl start ufw
    sudo systemctl status ufw.service

Status:

<img width="auto" alt="image" src="https://user-images.githubusercontent.com/101214286/236705695-6aee2ea0-57b7-49ac-a7ef-c10a4f04346d.png">

Merkintä (exited) tarkoittaa sitä, että UFW ei ole tällä hetkellä aktiivisessa käytössä, mutta on kuitenkin päällä.

Tämän jälkeen konfiguroin UFW:n sallimaan SSH-yhteyden ja aktivoin lopuksi säännön.

    sudo ufw allow openssh
    sudo ufw enable

Katsoin lopputuloksen komennolla `sudo ufw status`:

    Status: active

    To                         Action      From
    --                         ------      ----
    OpenSSH                    ALLOW       Anywhere
    OpenSSH (v6)               ALLOW       Anywhere (v6)

Huom. Yleensä myös esim. portit 80 ja 443 ovat auki tai avataan, mutta tämän projektin kannalta se ei ole olennaista. Kokeilin yhdistää SSH:lla a001-koneelta amasterille sekä toisinpäin. Se onnistui molemmilla kerroilla. Kuvassa a001 > amaster. 

<img width="auto" alt="image" src="https://user-images.githubusercontent.com/101214286/236806945-4b68199a-8c15-41e9-aa6e-8d515363a984.png">

Olin jo aikaisemmin tehnyt SSH-avainten generoinnin ja muut tarvittavat toimenpiteet eli ei ollut ratkaistavia yhteysongelmia. Halusin vielä kokeilla, että kiellän Telnetin UFW:ssä ja testaan sen. Ajoin siis komennot 

    sudo ufw deny telnet
    sudo ufw enable
    
Tarkistin, että status näytti oikealta:

    Status: active

    To                         Action      From
    --                         ------      ----
    OpenSSH                    ALLOW       Anywhere
    23/tcp                     DENY        Anywhere
    OpenSSH (v6)               ALLOW       Anywhere (v6)
    23/tcp (v6)                DENY        Anywhere (v6)
    
Varmistin, että Telnet on asennettu koneeseen komennolla `sudo apt-get install telnet` ja kokeilin muodostaa telnet-yhteyden amaster-koneeseen.

    vagrant@a001:~$ telnet 192.168.12.3
    Trying 192.168.12.3...

Tämä tarkoittaa sitä, että UFW:n konfiguraatiot on onnistuneet ja Telnet-yhteys blokataan. Yhteys siis jatkaa yrittämistä, mutta sitä ei sallita. Jonkin ajan päästä tulee ilmoitus, että yhteyttä ei pystynyt muodostamaan:

    telnet: Unable to connect to remote host: Connection timed out

## UFW:n automatisointi

Seuraavaksi loin kansion, johon lisäsin tilan: `sudo mkdir -p /srv/salt/mini`. Komento siis luo pääkäyttäjän oikeuksien avulla mini-kansion annettuun sijaintiin ja kaikki puuttuvat kansiot sen edeltä. Sinne lisään tiedoston init.sls komennolla `sudoedit init.sls`. Salt-tilan sisältö:

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
        - name: ufw allow 22
    
    ufw_deny_telnet:
      cmd.run:
        - name: ufw deny 23

Ensimmäinen kohta asentaa UFW-palomuurin, seuraava asentaa ja käynnistää SSH:n. Kolmas sallii SSH-yhteyden ja viimeinen kieltää Telnet-ytheyden. Ajoin komennon, jonka tarkoitus on vain testata menisikö tilat läpi oikeassa tapauksessa. En halunnut vielä ajaa ns. oikeaa tilaa ennen kuin olin varma, että tiedosto on tehty oikein.

    sudo salt 'a001' state.apply mini test=True

Siitä tuli virheilmoitus:

<img width="auto" alt="image" src="https://user-images.githubusercontent.com/101214286/236854004-38becafb-76bb-43aa-a30d-7ffb7cb553b3.png">

Jonka totesin johtuvan siitä, että Saltin käyttämät portit 4505 ja 4506 ovat estettyinä. Lisäsin siis vielä manuaalisesti nämä portit toimiviksi amaster-koneen UFW:lle ja päivitin listan.

    sudo ufw allow 4505/tcp && sudo ufw allow 4506/tcp
    sudo ufw reload
 
Päivittynyt taulukko näytti tältä:

    Status: active

    To                         Action      From
    --                         ------      ----
    OpenSSH                    ALLOW       Anywhere
    23/tcp                     DENY        Anywhere
    4505/tcp                   ALLOW       Anywhere
    4506/tcp                   ALLOW       Anywhere
    OpenSSH (v6)               ALLOW       Anywhere (v6)
    23/tcp (v6)                DENY        Anywhere (v6)
    4505/tcp (v6)              ALLOW       Anywhere (v6)
    4506/tcp (v6)              ALLOW       Anywhere (v6)

Kokeilin ajaa komennon uudestaan ja vastaus tuli normaalisti, eikä tilasta tullut virheilmoituksia. Päätin siis ajaa tilan molemmille koneille:

    sudo salt '*' state.apply mini

Tässä tuloste toiselta koneelta (Unohdin ottaa kuvan, joten otin sen myöhemmin pienen muokkauksen jälkeen).

    a001:
    ----------
          ID: ufw
    Function: pkg.installed
      Result: True
     Comment: All specified packages are already installed
     Started: 18:38:36.024312
    Duration: 28.241 ms
     Changes:
    ----------
          ID: openssh
    Function: pkg.installed
        Name: openssh-server
      Result: True
     Comment: All specified packages are already installed
     Started: 18:38:36.052748
    Duration: 7.354 ms
     Changes:
    ----------
          ID: openssh
    Function: pkg.installed
        Name: openssh-client
      Result: True
     Comment: All specified packages are already installed
     Started: 18:38:36.060237
    Duration: 6.987 ms
     Changes:
    ----------
          ID: openssh
    Function: service.running
        Name: sshd
      Result: True
     Comment: The service sshd is already running
     Started: 18:38:36.069151
    Duration: 42.211 ms
     Changes:
    ----------
          ID: ufw_allow_ssh
    Function: cmd.run
        Name: ufw allow 22
      Result: True
     Comment: Command "ufw allow 22" run
     Started: 18:38:36.114709
    Duration: 115.684 ms
     Changes:
              ----------
              pid:
                  17739
              retcode:
                  0
              stderr:
              stdout:
                  Skipping adding existing rule
                  Skipping adding existing rule (v6)
    ----------
          ID: ufw_deny_telnet
    Function: cmd.run
        Name: ufw deny 23
      Result: True
     Comment: Command "ufw deny 23" run
     Started: 18:38:36.230728
    Duration: 123.654 ms
     Changes:
              ----------
              pid:
                  17753
              retcode:
                  0
              stderr:
              stdout:
                  Skipping adding existing rule
                  Skipping adding existing rule (v6)

    Summary for a001
    ------------
    Succeeded: 6 (changed=2)
    Failed:    0
    ------------
    Total states run:     6
    Total run time: 324.131 ms

Menin vielä kokeilemaan yhteyksiä minioneille. Avasin siis uudet terminaalit ja testasin yhteyttä SSH:lla ja Telnetillä. UFW-muutokset toimivat.

Testi koneella a002:

<img width="auto" alt="image" src="https://github.com/annihuh/Miniprojekti/assets/101214286/d93ee84d-98f8-4f7b-a1e2-bd951aca4193">

## WireGuard VPN käsin

Aloitin WireGuardin asennuksen amaster-koneella päivittämällä taas koneen ja sen jälkeen ajamalla komennon `sudo apt-get install wireguard`. Sen jälkeen aloin luomaan yksityistä ja julkista avainparia, käytin komentoja `wg genkey` ja `wg pubkey` luomaan ne. Samalla lisäsin nämä avaimet WireGuardin konfigurointitiedostoon sekä muutin oikeuksia `chmod`, että kuka tahansa ei pääse lukemaan yksityistä avainta, koska se on oletuksena kaikkien luettavissa. 

Siis aluksi ajoin komennon, joka luo avaimen ja joka samalla kopioi sen haluttuun sijaintiin. Eli `sudo tee` lukee edellisen komennon tuloksen ja kirjoittaa sen private.key-tiedostoon.

    wg genkey | sudo tee /etc/wireguard/private.key

Tämän jälkeen muokkasin yksityisen avaimen lukuoikeudet muilta kuin rootilta (g = group, o = others, = eli poista).

    sudo chmod go= /etc/wireguard/private.key

Terkistin tämän jälkeen rootilla, että avain oli generoitunut oikeaan paikkaan `sudo cat /etc/wireguard/private.key`. Generointi oli onnistunut. Seuraavaksi generoin vastaavan julkisen avaimen, jonka teen yksityisen avaimen avulla. Se onnistui tällä komennolla. 

    sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key

Ensimmäinen osio lukee private.key-avaimen, toinen generoi uuden julkisen avaimen vastaamaan yksityistä avainta  ja viimeinen vaihe kirjoittaa avaimen sijaintiin `/etc/wireguard/public.key`. Komento oli onnistunut, koska ajamisen jälkeen tulostui rivi, joka oli generoitunut avain: `S0RuAg+2cJz4dXp6f3W1GQQ1xsOK9lHnEuE8YsGtdDk=`. Molempien avainten generointi WireGuard-palvelimelle onnistui. Seuraavaksi valitsin IPv4-osoitealueen, jota käytän VPN-verkkona `172.16.0.0/24` sekä päätin ns. tunneliosoitteen `172.16.0.1`, jonka kautta VPN-yhteys toimii. 

Kun kaikki edellämainittu on tehty ja valittu etenin vaiheeseen, jossa teen uuden WireGuard konfigurointitiedoston kansioon `/etc/wireguard/wg0.conf`. Tiedoston sisältö tässä vaiheessa:

    [Interface]
    PrivateKey = yksityinen avain
    Address = 172.16.0.1/24
    ListenPort = 51820
    SaveConfig = true

Ylhäältä alas lueteltuna kohdat tarkoittavat: ensimmäisenä määritellään, että muokkauksen kohteena on interface-asetukset, toisena on aiemmin luotu yksityinen avain, kolmantena kerrotaan valittu ipv4-osite, neljäntenä määritellään WireGuardin käyttämä portti ja viimeinen kohta varmistaa sen, että kun WireGuardin interface/liittymä on suljettuna kaikki muutokset tallennetaan konfigurointitiedostoon. Tallensin tiedoston ja jatkoin eteenpäin.



## WireGuardin automatisointi



## Lähteet

https://www.cyberciti.biz/faq/how-to-configure-firewall-with-ufw-on-ubuntu-20-04-lts/

https://docs.saltproject.io/en/getstarted/config/functions.html

https://docs.saltproject.io/salt/user-guide/en/latest/topics/states.html

https://docs.saltproject.io/salt/user-guide/en/latest/topics/requisites.html#requisites

https://github.com/rikurikurikuriku/Palvelinten-hallinta/blob/H7-Oma-Moduli/init.sls

https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-debian-11

