class openvz {
  $enhancers = [ "vzkernel", "vzctl", "vzctl-core", "vzdump", "vzquota" ]
  package { $enhancers: ensure => "installed" }
}
