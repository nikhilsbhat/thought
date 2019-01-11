require "#{File.dirname(__FILE__)}/media_wiki_aws_client"

module MediaWikiApp
  class MediaWikiDeleteBase < Chef::Knife

    include MediaWikiAwsBase

#-------------------load-balancers will be deleted here------------------------------
    def delete_loadbalancer(name)

        exists = aws_connection_elb.describe_load_balancers({
          load_balancer_names: [ name ], 
        })
        if !exists.nil?
            resp = aws_connection_elb.delete_load_balancer({
              load_balancer_name: name, 
            })
            if !resp.nil?
                return "load balancer deleted successfully",true
		    else
                return "we encountered error while deleting loadbalancer",false
		    end
        else
            return "cloud not find the loadbalancer which you are trying to delete",false
        end

    end

    def delete_server(node_name)
        #yet to be implemented. If I get some time I might complete this.
        # TODO. Delete server the respective cloud
    end

  end
end
