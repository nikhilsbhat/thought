require_relative 'helper'

class Chef
  class Resource::MediaWiki < Resource::LWRPBase
    resource_name :media_wiki

    # Chef attributes
    identity_attr :name

    # Actions
    actions :configure, :loadlocalsettings
    default_action :configure

    attribute :wiki_home,
              kind_of: String,
              default: '/var/lib/mediawiki'
  end
end

class Chef
  class Provider::MediaWiki < Provider::LWRPBase
    use_inline_resources

    include Wikimedia::WikidirHelpers

    provides :media_wiki

    action :configure do

      install_wiki = proc do
        if skip_configure "/var/www/html/mediawiki"
          Chef::Log.warn("wiki media already installed - skipping")
        else
          Chef::Log.warn("untaring the files of wiki media")
          untar_mediawiki '/tmp/mediawiki/medaiwiki.tar.gz', '/tmp/mediawiki/media'
          Chef::Log.warn("creating symlink")
          mv_and_link_mediawiki
          Chef::Log.warn("wiki media installed successfully")
        end
      end

      converge_by("Configure #{new_resource}",&install_wiki)

    end

    action :loadlocalsettings do

      loadsettings = proc do

        my_secret_key = Chef::EncryptedDataBagItem.load_secret ::File.join(node['sql']['secretpath'],"sqlsecret")
        passwords = Chef::EncryptedDataBagItem.load("sql", "mysql", my_secret_key)
        sql_node = search(:node, "role:wikisql")
        if sql_node.empty?
          dbaddress = '127.0.0.1'
          dbtype = 'unknown'
          dbuser = passwords["dbuser"]
          dbpassword = passwords["dbpassword"]
        else
          dbaddress = sql_node.first["cloud"]["public_ipv4"]
          dbtype = sql_node.first["sql"]["type"]
          dbuser = passwords["dbuser"]
          dbpassword = passwords["dbpassword"]
        end
        localsettingphp = ::File.join(new_resource.wiki_home, "LocalSettings.php")

        loadsetting = Chef::Resource::Template.new(localsettingphp, run_context)
        loadsetting.cookbook('wikimedia')
        loadsetting.source('local-settings.php.erb')
        # user can be anything but setting to root as I do not have time to deal with user now.
        loadsetting.owner 'root'
        loadsetting.group 'root'
        loadsetting.mode  '0755'
        loadsetting.variables(
          address:     node['cloud']['public_ipv4'],
          dbaddress:   dbaddress,
          dbtype:      dbtype,
          dbuser:      dbuser,
          dbpassword:  dbpassword
        )
        loadsetting.run_action(:create)
      end

      converge_by("Configure #{new_resource}",&loadsettings)

    end

  end
end
