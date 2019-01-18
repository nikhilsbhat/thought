# WikiMedia Cookbook

## Scope

This cookbook is responsible for installing and configuring wikimedia.

### Dependencies

This cookbook does not configure usable wikimedia with out dependencies, and is dependent on apache2 and php. For the same one has to use a cookbook by name 'wikimedia_base' which just does the job for you.

## Usage

Place a dependency on the wikimedia cookbook in your cookbook's metadata.rb.
If you need to installed from this cookbook then just use `wikimedia::default` in your recipe or role.

```ruby
depends 'wikimedia'
```

Then, in a recipe:

```ruby
media_wiki 'medaiwiki' do
  action :configure
end

media_wiki 'setting' do
  wiki_home node['medaiwiki']['home_path'] # path to home of wiki, the declare is taken as default.
  action    :loadlocalsettings
end

```
