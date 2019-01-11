require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/media_wiki_common"

# For the people who have doubts why we have custom server create 
# though there is availability of 'knife ec2' to create server?
# Answer is, we use packer to build custom image and it takes care of registering image with server
# all we need to do is to spin up the instance and this guy does just that.
module MediaWikiApp
  class MediaWikiServerCreate < Chef::Knife

    include MediawikiCommon
    deps do
      require "#{File.dirname(__FILE__)}/base/media_wiki_create_base"
      MediaWikiApp::MediaWikiCreateBase.load_deps
    end

    banner 'knife mediawiki server create (options)'

    option :node_name,
        :short => '-n NODE_NAME',
        :long => '--node-name NODE_NAME',
        :description => 'Name your node/instance which will be created using this command. This is just to name your instance not chef node.'

    option :network,
        :long => '--network SUBNET_ID',
        :description => 'Network refers to subnet here, as we are creating server in aws pass ID of subnet in which server has to be created.'

    option :security_group,
        :short => '-s SECURITY_GROUP_ID',
        :long => '--security-group SECURITY_GROUP_ID',
        :description => 'The ID of security group which has to be assigned to loadbalancer. If not specified we will read knife and pick the default'

    option :image_id,
        :short => '-i IMAGE_ID',
        :long => '--image-id IMAGE_ID',
        :description => 'Id of the image/chef-node which has to be brought up'

    option :key_name,
        :short => '-k AWS_KEY_PAIR',
        :long => '--key-name AWS_KEY_PAIR',
        :description => 'name of aws key pair which has to be assigned with the instance, so that one can access the machine created.'

    option :flavor,
        :short => '-f FLAVOR',
        :long => '--flavor FLAVOR',
        :description => 'The flavor of server. The hardware capacities of the machine'

    option :assign_public_ip,
        :short => '-a ASSIGN_PUBLIC_IP',
        :long => '--assign-public-ip ASSIGN_PUBLIC_IP',
        :description => 'disable this flag if assigning public ip is not of yor choice, but this defaults to true',
        :default => true

    def run

        if !config[:security_group].nil?
            security = config[:security_group]
        else
            security = Chef::Config[:knife][:security_group_id]
        end
        if !config[:key_name].nil?
            key = config[:key_name]
        else
            key = Chef::Config[:knife][:ssh_key_name]
        end
        if !config[:flavor].nil?
            flavor = config[:flavor]
        else
            flavor = Chef::Config[:knife][:flavor]
        end
        create_server(security,key,flavor)
    end

    def create_server(security,key,flavor)

      client = MediaWikiCreateBase.new
      # server gets created here
      puts "#{ui.color('spinning up the server with chef registration built-in', :cyan)}"
	  puts security,key,flavor
      server = client.create_aws_server config[:node_name], config[:network] ,security, config[:image_id], key, flavor, config[:assign_public_ip]
      puts "#{ui.color('server created successfully', :cyan)}"
      puts ""

      # printing details of the instance created
      puts ''
      puts "========================================================="
      server.each do |key,value|
          puts "#{ui.color(key, :magenta)}          : #{value}"
      end
      puts "========================================================="
      puts ''

    end

  end
end
