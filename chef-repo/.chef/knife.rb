# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "bhatnikhil"
client_key               "#{current_dir}/bhatnikhil.pem"
chef_server_url          "https://api.chef.io/organizations/testtree"
cookbook_path            ["#{current_dir}/../cookbooks"]
syntax_check_cache_path  ["/root/syntaxcache"]
knife[:editor]                = "vi"
knife[:ssh_user]              = 'ubuntu'

knife[:node_name]             = "bhatnikhil"
knife[:client_key]            = "#{current_dir}/bhatnikhil.pem"
knife[:chef_server_url]       = "https://api.chef.io/organizations/testtree"
# The data required by knife to authenticate with AWS console/account && to povision in it.
knife[:aws_access_key_id]     = 'AKIAIIBURSFZ2WWMC7OA'
knife[:aws_secret_access_key] = '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'

# Declaring few aspects here to make knife call cleaner.
knife[:image]                 = 'ami-04ea996e7a3e7ad6b'
knife[:ssh_key_name]          = 'chef-coe-ind'
knife[:identity_file]         = ["#{current_dir}/pun-chef-coe.pem"]
knife[:ssh_port]              = 22
knife[:region]                = "ap-south-1"
knife[:security_group_id]     = "sg-06efe0a7ff3dde6c6"
knife[:flavor]                = "t2.micro"
