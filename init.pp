class httpditzgeek 
{
	$doc_root = "/var/www/itzgeek"
	$http_port = 82
	
	exec
        {
                'yum update':
                command => '/usr/bin/yum update'
        }

    	package 
	{ 
		'httpd':
		ensure => present,
		subscribe => Exec['yum update']
    	} 
    	file 
	{ 
		"/var/www/itzgeek":  # Creating Document Root
	     	ensure => "directory",
	     	owner  => "apache",
      		group  => "apache",
      		mode   => '0750',
    	} 
 	file 
	{ 
		'/var/www/itzgeek/index.html': # Creating Index file
     		ensure  => file,
     		content => "Index HTML Is Managed By Puppet",
     		mode    => '0644',
   	} 
    	file 
	{ 
		'/etc/httpd/conf.d/custom_itzgeek.conf': # Path to the file on client machine 
	        ensure => file,
      		mode   => '0600',
		content => template("/etc/puppetlabs/code/environments/production/modules/${module_name}/files/vhost.erb"),
      		#source => 'puppet:///modules/httpditzgeek/custom_itzgeek.conf', # Path to the custom file on puppet server
    	}

    	service 
	{ 
		'httpd':
     		ensure => running,
      		enable => true,
		#refreshonly => true,
		#subscribe => Package['httpd]
    	}

	
	

	exec
        { 
		'semanage-port':
    		command => "semanage port -a -t http_port_t -p tcp ${http_port}",
    		path => "/usr/sbin",
    		require => Package['policycoreutils-python'],
    		before => Service['httpd'],
    		subscribe => Package['httpd'],
		#subscribe => Exec['yum update']
    		refreshonly => true,
  	}


	exec
	{
                'firewall-cmd':
                command => "firewall-cmd --zone=public --add-port=${http_port}/tcp --permanent",
                path => "/usr/bin/",
                refreshonly => true,
                #subscribe => Package['httpd'],
		#logoutput => true,
		#before => Service['httpd'],
		subscribe => Package['httpd'],
		#subscribe => Service['firewalld']
                #require => Exec['semanage port'],
        }




	service
        {
                'firewalld':
                ensure => running,
                enable => true,
                hasrestart => true,
                subscribe =>Package['httpd'],
        }
	
	package
        {
                'policycoreutils-python':
                ensure => installed,
                #require => Exec['yum update']
        }

}
