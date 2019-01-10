require 'chef/knife'
require 'packer-config'

module MediaWikiApp
  class MediawikiImageCreate < Chef::Knife

    banner 'knife mediawiki image create (options)'

    option :runlist,
        :short => '-r RUN_LIST',
        :long => '--runlist RUN_LIST',
        :description => "The list of roles/recipes that has to be applied to the machine. Pass value by comma separated value",
        :proc => Proc.new { |i| i.split(/,/) }

    option :nodename,
        :short => '-n NODE_NAME',
        :long => '--nodename NODE_NAME',
        :description => "Name of the node which you has to be assigned and tagged to the image which will be created"

    option :environment,
        :short => '-e SERVER_ENVIRONMENT',
        :long => '--environment SERVER_ENVIRONMENT',
        :description => "In which Environment the server has to be created"

    option :flavor,
        :short => '-f FLAVOR',
        :long => '--flavor FLAVOR',
        :description => "The flavor of server. The hardware capacities of the machine",
        :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }

    option :machine_user,
        :short => '-m MACHINE_USER',
        :long => '--machine-user MACHINE_USER',
        :description => "Name of the user that has to be assigned fo VM.",
        :default => "ubuntu"

    option :image_id,
        :short => '-i IMAGE_ID',
        :long => '--image IMAGE_ID',
        :description => "Id of base image on which custoom image has to be built, if not image specifieed in knife will be taken automatically"

    option :packer_provisioner,
        :long => '--packer-provisioner PACKER_PROVISIONER',
        :description => "Name of packer provisioner which has to be used to provision image. If not passed it defaults to 'chef'.",
        :default => "chef"

    option :packer_builder,
        :long => '--packer-builder PACKER_BUILDER',
        :description => "Name of packer builder type which has to be used while building custom image. If not passed it defaults to 'amazon-ebs'.",
        :default => "amazon-ebs"

    option :packer_option,
        :long => '--packer_option PACKER_OPTION',
        :description => "Operation that has to be performed on packer template. ex: validate/build",
        :default => "validate"

    option :region,
        :long => '--region REGION',
        :description => "Region of cloud where the image has to be created.",
        :default => "ap-south-1"

    def run

        pconfig = packer_config
        builder = get_packer_builder pconfig
        provisioner = get_packer_provisioner pconfig
        case config[:packer_option]
        when 'validate'
            validate = packer_validate pconfig
			puts validate
        when 'build'
            build = packer_build pconfig
			puts build
        else
            packer_validate pconfig
        end

    end

    def packer_config
		puts "packer-amazon-#{config[:nodename]}.json"
        pconfig = Packer::Config.new "packer-amazon-#{config[:nodename]}.json"
        pconfig.description "this will build a customized image for mediawiki"
        #pconfig.add_variable 'environment', config[:environment]
        #pconfig.add_variable 'serverurl', Chef::Config[:knife][:chef_server_url]
        #pconfig.add_variable 'nodename', config[:nodename]
        # fetching aws credentials from knife and it works only this way.
        #pconfig.add_variable 'aws_access_key', Chef::Config[:knife][:aws_access_key_id]
        #pconfig.add_variable 'aws_secret_key', Chef::Config[:knife][:aws_secret_access_key]
        return pconfig
    end

    def packer_build(config)
        resp = config.build
        return resp
    end

	def packer_validate(config)
        resp = config.validate
        return resp
	end

	def get_packer_provisioner(pconfig)
        provisioner = decide_provisioner pconfig, config[:packer_provisioner]
        provisioner.server_url Chef::Config[:knife][:chef_server_url]
        provisioner.chef_environment config[:environment]
        provisioner.node_name config[:nodename]
        provisioner.run_list config[:runlist]
        # fetching validation client_name and client_key_path from knife, and it works only this way.
        provisioner.validation_client_name Chef::Config[:knife][:node_name]
        provisioner.validation_key_path Chef::Config[:knife][:client_key]
        # enabling the below flags to make sure the image will get registerd to chef
        # and stays as it is till we bring up the server from the image.
        provisioner.skip_clean_node true
        provisioner.skip_clean_client true
        # below options are not available in default packer-config package, and is available only on the edited gem for mediawiki
        provisioner.staging_directory "/etc/chef"
        provisioner.skip_clean_staging_directory true
        return provisioner
    end

	def get_packer_builder(pconfig)
        builder = decide_builder pconfig, config[:packer_builder]
        builder.access_key Chef::Config[:knife][:aws_access_key_id]
        builder.secret_key Chef::Config[:knife][:aws_secret_access_key]
        if config[:region] != ""
            builder.region config[:region]
			puts config[:region]
        else
			puts config[:region]
            builder.region Chef::Config[:knife][:region]
        end
        if !config[:image_id].nil?
            builder.source_ami config[:image_id]
        else
            # it defaults to id declared in knife, and declaring id of base image in knife.rb is mandatory
            builder.source_ami Chef::Config[:knife][:image]
        end
        if !config[:flavor].nil?
            builder.instance_type config[:flavor]
        else
            builder.instance_type "t2.micro"
        end
        builder.ssh_username config[:machine_user]
        builder.ami_name config[:nodename]
        if config[:machine_user] == "ubuntu"
            builder.communicator "ssh"
        end
        return builder
    end

	def decide_provisioner(config, name)
        case name
        when 'chef'
            return config.add_provisioner Packer::Provisioner::CHEF_CLIENT
            # adding further provisioners in the case soon if it is required.
        else
            return config.add_provisioner Packer::Provisioner::CHEF_CLIENT
        end
	end

	def decide_builder(config, name)
        case name
        when 'aws-ebs'
            return config.add_builder Packer::Builder::AMAZON_EBS
            # adding further provisioners in the case soon if it is required.
        else
            return config.add_builder Packer::Builder::AMAZON_EBS
        end
	end

  end
end
