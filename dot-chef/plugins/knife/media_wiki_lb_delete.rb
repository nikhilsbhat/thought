require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/media_wiki_common"

module MediaWikiApp
  class MediaWikiLoadBalancerDelete < Chef::Knife

    include MediawikiCommon
    deps do
      require "#{File.dirname(__FILE__)}/base/media_wiki_delete_base"
      MediaWikiApp::MediaWikiDeleteBase.load_deps
    end

    banner 'knife mediawiki load balancer delete (options)'

    option :name,
        :short => '-n LOAD_BALANCER_NAME',
        :long => '--name LOAD_BALANCER_NAME',
        :description => 'name of the loadbalancer which has to be deleted.'

    option :clean_data,
        :short => '-c CLEAN_LOADBALANCER_ENTRY',
        :long => '--clean-data CLEAN_LOADBALANCER_ENTRY',
        :description => 'one has to turn this flag off if he do not want to clear the data of loadbalancer stored in loadbalancer.',
        :default => true

    def run

        stat = delete_lb
        puts "#{ui.color(stat.first, :cyan)}"
        if stat.last
            if config[:clean_data] != false
                if delete_lb_data
                    puts "#{ui.color('load balancer data deleted successfully from chef', :cyan)}"
                else
                    puts "#{ui.color('an error occured while de registering loadbalacer from chef', :cyan)}"
                end
            else
                puts "#{ui.color('I am not deleting the data of load balancer as you opted out of it', :cyan)}"
            end
        end

    end

#------------------------creation of lb------------------------------
    def delete_lb
        lbname = fetch_data "loadbalancers", config[:name], "ELB-NAME"
        client = MediaWikiDeleteBase.new
        delete = client.delete_loadbalancer lbname
        return delete
    end


    def delete_lb_data
        status = delete_item_from_databag "loadbalancers","#{config[:name]}"
        return status
    end

  end
end
