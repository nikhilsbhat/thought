require_relative 'helper'

class Chef
  class Resource::MediaWiki < Resource::LWRPBase
    resource_name :media_wiki

    # Chef attributes
    identity_attr :name

    # Actions
    actions :configure
    default_action :configure

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

  end
end
