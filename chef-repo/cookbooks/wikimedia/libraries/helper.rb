require 'zlib'
require 'fileutils'
require 'rubygems/package'

module Wikimedia
  module WikidirHelpers

  
    def untar_mediawiki(file_path,destination)
      Gem::Package::TarReader.new (Zlib::GzipReader.open file_path) do |tar|
        tar.each do |tarfile|
          destination_file = File.join destination, tarfile.full_name

          if tarfile.directory?
            FileUtils.mkdir_p destination_file
          else
            destination_directory = File.dirname(destination_file)
            FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
            File.open destination_file, "wb" do |f|
              f.print tarfile.read
            end
          end
        end
      end    
    end

    def skip_configure(directory)
      if (File.directory?(directory))
        if File.lstat(directory).symlink?
          return true
        else
          return false
        end
      else
        return false
      end
    end

    def mv_and_link_mediawiki
      FileUtils.copy_entry "/tmp/mediawiki/media/mediawiki-#{node['medaiwiki']['main_version']}.#{node['medaiwiki']['sub_version']}", node['medaiwiki']['home_path']
      stat = link_mediawiki node['medaiwiki']['home_path'], "/var/www/html/mediawiki"
      return stat
    end

    def link_mediawiki(src,dest)
      File.symlink src, dest
      if File.lstat(dest).symlink?
        return true
      else
        return false
      end
    end

  end
end
