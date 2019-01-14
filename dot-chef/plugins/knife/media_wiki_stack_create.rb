require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/media_wiki_common"

# make sure you pass the ID's of images for which you need to create server.
# if not, we will read the data bag to get the latest entry made for respective image id in there.
# if image id is not stored there, be ready to see error.
module MediaWikiApp
  class MediawikiStackCreate < Chef::Knife

    include MediawikiCommon
    deps do
      require "#{File.dirname(__FILE__)}/base/media_wiki_create_base"
      MediaWikiApp::MediawikiCreateBase.load_deps
    end

    banner 'knife mediawiki stack create (options)'

    option :wikicount,
        :short => '-w WIKI_MEDIA_COUNT',
        :long => '--wikicount WIKI_MEDIA_COUNT',
        :description => "count of MediaWiki machines required to be brought up as part of this stack creation",
        :default => 2

    option :mysqlcount,
        :short => '-m MYSQL_COUNT',
        :long => '--mysqlcount MYSQL_COUNT',
        :description => "count of MySql machines required to be brought up as part of this stack creation",
        :default => 1

    option :lbname,
        :short => '-l LOAD_BALANCER_NAME',
        :long => '--lbname LOAD_BALANCER_NAME',
        :description => "name/dns/arn of the loadbalancer which has to be placed infront of MediaWiki instances. If not passed, the latest entry from databag created by 'knife mediawiki lb create' will be considered.",
        :default => 1

    option :wikimage,
        :long => '--wikimage MEDIA_WIKI_IMAGE_ID',
        :description => "Id/name of the image which has to be considered while bringing up the instance for MediaWiki. If not passed, the latest entry from databag created by 'knife mediawiki image create' will be considered"

    option :mysqlimage,
        :long => '--mysqlimage MYSQL_IMAGE_ID',
        :description => "Id/name of the image which has to be considered while bringing up the instance for MySql. If not passed, the latest entry from databag created by 'knife mediawiki image create' will be considered"

    option :store_info,
        :short => '-s STORE_STACK_INFO',
        :long => '--store-info STORE_STACK_INFO',
        :description => "use this flag if in case you need to store the information regarding the stack which will be created by this plugin, this will make use of databag to store details",
        :default => false

    option :wikinetwork,
        :long => '--wiki-network WIKI_NETWORK',
        :description => "The network in which you wish to provision wiki instances. If not passed we will try reading it from appropriate databag if not you will be sent an error. Enter a comma separated value",
        :proc => Proc.new { |i| i.split(/,/) }

    option :mysqlnetwork,
        :long => '--mysql-network MYSQL_NETWORK',
        :description => "The network in which you wish to provision mysql instances. If not passed we will try reading it from appropriate databag if not you will sent an error."

    def run

      if check_if_item_exists("loadbalancers", "#{config[:lbname]}")
        @lb_name = fetch_data "loadbalancers", "#{config[:lbname]}", "ELB-NAME"
        resp = create_stack
        register_instance_with_lb resp
      else
        puts "#{ui.color('Load balancer to which you want to register servers does not exists', :cyan)}"
        puts "#{ui.color('there is no point creating further resources hence weapons down', :cyan)}"
      end

    end

    def create_stack
      stack = [create_wiki_server, create_mysql_server]
      response = []
	  n = 0
      stack.each do |thread|
        thread.each do |t|
          t.join
          response[n] = t[:output]
          n += 1
        end
      end
      return response
    end

    def register_instance_with_lb(resp)

      instances = []
      resp.each_with_index do |res,ind|
        if (res["Nodename"]).include? "wiki-node"
          instances[ind] = res["InstanceId"]
        end
      end
      client = MediaWikiApp::MediawikiCreateBase.new
      instances.each do |inst_id|
        client.register_server_to_load_balancers @lb_name, inst_id
      end
    end

    def create_wiki_server
      if config[:wikimage].nil?
        image = get_nodes_imgid("MEDIAWIKI")
      else
        image = config[:wikimage]
      end

      threads = Array.new(config[:wikicount].to_i)
	  network = config[:wikinetwork].sample(1).to_s.tr("[]", '').tr('"', '')
      (threads.length).times do |i|
        threads[i] = Thread.new { Thread.current[:output] = create_machine "wiki-node-#{i}", network, "", image, "", "t2.micro", true }
      end
      return threads
    end

    def create_mysql_server
      if config[:mysqlimage].nil?
        image = get_nodes_imgid("MYSQL")
      else
        image = config[:mysqlimage]
      end
      threads = Array.new(config[:mysqlcount].to_i)
      (threads.length).times do |i|
        threads[i] = Thread.new { Thread.current[:output] = create_machine "mysql-node-#{i}", config[:mysqlnetwork], "", image, "", "t2.micro", false }
      end
      return threads
    end

    def register_with_load_balance

    end

    # this is well tested function which will yield last entry made for the image
    def get_nodes_imgid(item)
      id = fetch_raw_data "wikimedia", "nodes", item
      return id
    end

    def create_machine(nodename,network,secgroup,image,key,flavor,publicip)
      server = MediawikiServerCreate.new
      server.config[:node_name]        = nodename
      server.config[:network]          = network
      server.config[:security_group]   = Chef::Config[:knife][:security_group_id]
      server.config[:image_id]         = image
      server.config[:key_name]         = Chef::Config[:knife][:ssh_key_name]
      server.config[:flavor]           = flavor
      server.config[:assign_public_ip] = publicip
      response = server.run
    end

  end
end
