require "#{File.dirname(__FILE__)}/media_wiki_aws_client"

module MediaWikiApp
  class MediaWikiCreateBase < Chef::Knife

    include MediaWikiAwsBase

#-------------------load-balancers will be created here------------------------------
    def create_classic_loadbalancer(name,subnet_id1,subnet_id2,security_group,protocol,loadbalancerport,instanceprotocol,instanceport)
      elb = aws_connection_elb.create_load_balancer({
         load_balancer_name: name,
         subnets: [subnet_id1,subnet_id2,],
         security_groups: security_group,
          scheme: "internet-facing",
          listeners: [
           {
             protocol: protocol, # required, accepts HTTP, HTTPS
             load_balancer_port: loadbalancerport, # required
             instance_protocol: instanceprotocol,
             instance_port: instanceport,
           },],
          tags: [
              {
               key: "LoadBalancer",
               value: "#{name}-test",
              },],
       })

      dns_lb = aws_connection_elb.describe_load_balancers({
        load_balancer_names: ["#{name}"],
      })

       return dns_lb.load_balancer_descriptions[0].dns_name
     end

#--------------------------

    def create_health_check(elb_name,ping_path)
        health = aws_connection_elb.configure_health_check({
            health_check: {
              healthy_threshold: 2,
              interval: 30,
              target: "#{ping_path}",
              timeout: 3,
              unhealthy_threshold: 2,
            },
            load_balancer_name: "#{elb_name}", 
        })
    end
#----------------adding instances to load balancers--------------

    def register_server_to_load_balancers(elb_name,instanceid)

      puts "#{ui.color('Adding instances to load balancer', :cyan)}"
      puts "."
      puts "#{ui.color('Adding process is in progress', :cyan)}"
      puts "#{ui.color('Checking the requirements', :cyan)}"

      # adding instances to application load balancers
      aws_connection_elb.register_instances_with_load_balancer({
          load_balancer_name: "#{elb_name}",
             instances: [{ instance_id: instanceid,},],
      })
      puts "#{ui.color('Instance is successfully added to loadbalancer', :cyan)}"

    end

	def create_aws_server(node_name,network,security_group,image,ssh_key_name,flavor,assignpubIP)

        resp = aws_connection_client.run_instances({
             image_id: image, 
             instance_type: flavor, 
             key_name: ssh_key_name, 
             max_count: 1, 
             min_count: 1, 
             security_group_ids: [
                 security_group, 
             ], 
             subnet_id: network,
			 network_interfaces: [{
				associate_public_ip_address: assignpubIP
			 },],
             tag_specifications: [
                 {
                     resource_type: "instance", 
                     tags: [{
                         key: "Name", 
                         value: node_name, 
                     },], 
                 }, 
		     ],
        })
		return {"InstanceId" => resp.instances[0].instance_id, "Nodename" => resp.instances[0].tags[0].value, "ImageIdUsed" => resp.instances[0].image_id, "LaunchedAt" => resp.instances[0].launch_time, "NetworkCreatedIn" => resp.instances[0].subnet_id}

	end

  end
end
