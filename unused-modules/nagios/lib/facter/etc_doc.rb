#
# create a fact for each file in /etc/doc
#
# [main]
# pluginsync = true
# 
# must be in  /etc/puppet/puppet.conf
#

require 'facter'

# import etc doc bliss facts
if File.exist?('/etc/doc') 
  Dir.foreach('/etc/doc') do |fact|
    next if ['.','..','README'].include?(fact)
    Facter.add(fact.to_sym) do
      setcode do
        Facter::Util::Resolution.exec("cat /etc/doc/#{fact}")
      end
    end
  end
end
