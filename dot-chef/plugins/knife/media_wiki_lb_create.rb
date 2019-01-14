require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/media_wiki_common"

module MediaWikiApp
  class MediawikiLoadBalancerCreate < Chef::Knife

    include MediawikiCommon
    deps do
      require "#{File.dirname(__FILE__)}/base/media_wiki_create_base"
      MediaWikiApp::MediaWikiCreateBase.load_deps
    end

    banner 'knife mediawiki load balancer create (options)'

    option :listener_protocol,
        :long => '--listener-protocol HTTP',
        :description => 'Listener protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

    option :listener_instance_protocol,
        :long => '--listener-instance-protocol HTTP',
        :description => 'Instance connection protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

    option :listener_lb_port,
        :long => '--listener-lb-port 80',
        :description => 'Listener load balancer port (default 80)',
        :default => 80

    option :listener_instance_port,
        :long => '--listener-instance-port 80',
        :description => 'Instance port to forward traffic to (default 80)',
        :default => 80

    option :ssl_certificate_id,
        :long => '--ssl-certificate-id SSL-ID',
        :description => 'ARN of the server SSL certificate'

    option :name,
        :short => '-n ELB_NAME',
        :long => '--name ELB_NAME',
        :description => "The name of the elastic load balancer that has to be created"

    option :subnets,
        :long => '--subnets SUBNET_IDS',
        :description => "ID's of subnet which has to be attached with loadbalancer",
        :proc => Proc.new { |i| i.split(/,/) }

    option :security_group,
        :short => '-s SECURITY_GROUP_ID',
        :long => '--security-group SECURITY_GROUP_ID',
        :description => "The ID of security group which has to be assigned to loadbalancer. If not specified we will read knife and pick the default",
        :proc => Proc.new { |s| Chef::Config[:knife][:security_group_id] = s }

    option :ping_path,
        :short => '-p PING_PATH',
        :long => '--ping-path PING_PATH',
        :description => "The ping path to configure the health check for the classic loadbalancers. It looks something like: HTTP:80/index.html"


    def run

      if check_if_item_exists("loadbalancers", "#{config[:name]}")
          puts "#{ui.color('loadbalancer already exists with the name', :cyan)}  :#{config[:name]}-LB"
      else
          stat = create_lb
          puts stat
      end

    end

#------------------------creation of lb------------------------------
    def create_lb

        subnet_id1 = config[:subnets].first
        subnet_id2 = config[:subnets][1]

        stat = create_aws_classic_lb(subnet_id1,subnet_id2,config[:security_group])
        return stat
    end


    def create_aws_classic_lb(subnet_id1,subnet_id2,security_group)

      client = MediaWikiCreateBase.new
      # creation of load balancer
      puts "#{ui.color('creating load balancer for the environment', :cyan)}"
      elb_details = client.create_classic_loadbalancer("#{config[:name]}-LB",subnet_id1,subnet_id2,security_group,"#{config[:listener_protocol]}","#{config[:listener_lb_port]}","#{config[:listener_instance_protocol]}","#{config[:listener_instance_port]}")
      puts "#{ui.color('load balancer created', :cyan)}"
      puts ""
      puts "#{ui.color('creating health checks for the load balancer...', :cyan)}"
      puts "."

      #  creation of health check
      lb_health_checks = client.create_health_check("#{config[:name]}-LB","#{config[:ping_path]}")
      puts "."
      puts "#{ui.color('Health check created successfully', :cyan)}"
      puts ""

      # printing details of the loadbalancers
      puts ''
      puts "========================================================="
      puts "#{ui.color('lb-name', :magenta)}          : #{config[:name]}-LB"
      puts "#{ui.color('lb-dns', :magenta)}           : #{elb_details}"
      puts "========================================================="
      puts ''

      # storing data of loadbalancer
      if store_lb_data(elb_details)
          return "Load Balancer created successfully and stored the data of it"
      else
          return "An error occured while storing the data of loadbalancer created"
      end

    end

    def store_lb_data(dns)

        data = {
                'id' => "#{config[:name]}",
                'ELB-NAME' => "#{config[:name]}-LB",
                'ELB_DNS' => "#{dns}",
               }
        status = store_item_to_databag "loadbalancers",data,"#{config[:name]}"
    end

  end
end
