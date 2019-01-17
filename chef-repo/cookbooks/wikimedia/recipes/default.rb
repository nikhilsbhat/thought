# creates directory to run wikimedia under httpd service.
#directory node['medaiwiki']['home_path'] do
#  owner     'root'
#  group     'root'
#  mode      '0755'
#  recursive true
#end

# creates temporary directory to perform actions while installing.
# this will be cleaned after succesful installation.
directory '/tmp/mediawiki' do
  owner     'root'
  group     'root'
  mode      '0755'
  recursive true
end

# this is temporary and will be removed soon
directory "/var/www/html" do
  owner     'root'
  group     'root'
  mode      '0755'
  recursive true
end

# downloading the tar of mediawiki
Chef::Log.info(node['medaiwiki']['download_url'])
remote_file '/tmp/mediawiki/medaiwiki.tar.gz' do
  source   node['medaiwiki']['download_url']
  owner    'root'
  group    'root'
  mode     '0755'
  action   :create_if_missing
end

# Create runit service
media_wiki 'medaiwiki' do
  action :configure
end

skins = {
  'CologneBlue'  => 'https://gerrit.wikimedia.org/r/mediawiki/skins/CologneBlue',
  'Modern'       => 'https://gerrit.wikimedia.org/r/mediawiki/skins/Modern',
  'MonoBook'     => 'https://gerrit.wikimedia.org/r/mediawiki/skins/MonoBook',
  'Vector'       => 'https://gerrit.wikimedia.org/r/mediawiki/skins/Vector'
}

skins.each_with_index do |(name, repo), index|
  git name do
    repository repo
    reference "master"
    destination "/var/lib/mediawiki/skins/#{name}"
    action :sync
	not_if { ::File.directory?("/var/lib/mediawiki/skins/#{name}") }
  end
end

directory '/tmp/mediawiki' do
  owner     'root'
  group     'root'
  mode      '0755'
  recursive true
  action    :delete
end
