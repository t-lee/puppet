class site {
   file { '/tmp/index.php':
     ensure  => file,
     content => "<?php phpinfo() ?>\n",
     mode    => '0644',
   }
}






