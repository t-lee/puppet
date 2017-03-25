Facter.add('ipaddress_primary') do
  setcode do
    if Facter.value('ipaddress_eth0')
      Facter.value('ipaddress_eth0')
    else
      Facter.value('ipaddress')
    end
  end
end
