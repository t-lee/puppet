require 'facter'


Facter.add(:is_lxc) do
  confine :kernel => "Linux"
  setcode do
    Facter::Util::Resolution.exec('grep -q "lxc" /proc/1/cgroup && echo "true" || echo "false"')
  end
end

