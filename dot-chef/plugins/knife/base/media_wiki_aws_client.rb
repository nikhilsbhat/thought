require 'chef/knife'
require 'aws-sdk'

# A module that helps to establish connection with aws, 
# it can connect to any resource of aws if declared here. But do not import this module in required plugin.
# But limiting it to just load balancer as it is requirement at this point.
module MediaWikiApp
  module MediaWikiAwsBase

    def self.included(includer)
      includer.class_eval do

	  # Fetching the region from knife.rb is just to initialize the aws client, in future pass region
	  # as parameter while creating any resources. Mentioning default region in knife.rb is mandatory.
      def aws_connection_client
        @aws_connection_client ||= begin
          aws_connection_client = Aws::EC2::Client.new(
                 region: Chef::Config[:knife][:region],
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
        end
      end

      def aws_connection_elb
        @aws_connection_elb ||= begin
          aws_connection_elb = Aws::ElasticLoadBalancing::Client.new(
                 region: Chef::Config[:knife][:region],
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
            end
      end

      def aws_connection_elb2
        @aws_connection_elb2 ||= begin
          aws_connection_elb2 = Aws::ElasticLoadBalancingV2::Client.new(
                 region: Chef::Config[:knife][:region],
                 credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
          end
      end

      end
    end
  end
end
