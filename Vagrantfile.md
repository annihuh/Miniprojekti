# Alla Vagrantfilen sisältö. Käytössä kurssilla annettu pohja, jossa muutoksena koneiden nimet. Alkuperäinen luoja on kurssi opettaja, Tero Karvinen.

# -*- mode: ruby -*-
# vi: set ft=ruby :
# Copyright 2014-2023 Tero Karvinen http://TeroKarvinen.com

$minion = <<MINION
sudo apt-get update
sudo apt-get -qy install salt-minion
echo "master: 192.168.12.3">/etc/salt/minion
sudo service salt-minion restart
echo "See also: https://terokarvinen.com/2023/salt-vagrant/"
MINION

$master = <<MASTER
sudo apt-get update
sudo apt-get -qy install salt-master
echo "See also: https://terokarvinen.com/2023/salt-vagrant/"
MASTER

Vagrant.configure("2") do |config|
	config.vm.box = "debian/bullseye64"

	config.vm.define "a001" do |a001|
		a001.vm.provision :shell, inline: $minion
		a001.vm.network "private_network", ip: "192.168.12.100"
		a001.vm.hostname = "a001"
	end

	config.vm.define "a002" do |a002|
		a002.vm.provision :shell, inline: $minion
		a002.vm.network "private_network", ip: "192.168.12.102"
		a002.vm.hostname = "a002"
	end

	config.vm.define "amaster", primary: true do |amaster|
		amaster.vm.provision :shell, inline: $master
		amaster.vm.network "private_network", ip: "192.168.12.3"
		amaster.vm.hostname = "amaster"
	end
end
