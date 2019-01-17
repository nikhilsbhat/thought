# attributes used while installation and configuration if medaiwiki

default['medaiwiki']['main_version'] = '1.25'
default['medaiwiki']['sub_version'] = '6'
default['medaiwiki']['base_url'] = 'https://releases.wikimedia.org/mediawiki'
default['mediawiki']['core'] = true
default['medaiwiki']['download_url'] =
  case node['mediawiki']['core']
  when true
    "#{node['medaiwiki']['base_url']}/"\
    "#{node['medaiwiki']['main_version']}/"\
    "mediawiki-core-#{node['medaiwiki']['main_version']}.#{node['medaiwiki']['sub_version']}.tar.gz"
  when false
    "#{node['medaiwiki']['base_url']}/"\
    "#{node['medaiwiki']['main_version']}/"\
    "mediawiki-#{node['medaiwiki']['main_version']}.#{node['medaiwiki']['sub_version']}.tar.gz"
  end
default['medaiwiki']['home_path'] = '/var/lib/mediawiki'

default['sql']['secretpath'] = '/tmp/sql/'
