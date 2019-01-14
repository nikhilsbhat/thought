# knife-mediawiki

A custom knife plugin which lets you perform certain action with MediWiki and MySql.

It helps in creating loadbalancer in AWS, storing its value in chef.
It helps in creating custom images using Packer, for this I have used [packer-config](https://github.com/ianchesal/packer-config)
this packer blend plugin help in creating custom image.


## Download

    Since a custom gem is not built for this yet, if one has to use this plugins
	then folder containing plugins has to be placed under '.chef/plugins/' as 'knife'

## Requires

    This requires hashicorp packer to be pre-installed, 
	as per the [packer-config](https://github.com/ianchesal/packer-config) it should satisfy below condition.
* [Packer](http://packer.io) version 0.8.5 or higher

## knife mediawiki Subcommands

This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a `--help` flag

### knife mediawiki stack create

```bash
    knife mediawiki stack create (options)
```

This lets you spawn up a stack, which constitutes spinning [MediaWiki]("https://www.mediawiki.org/wiki/MediaWiki") along with its primary component which is MySql.
It will put the MediaWiki servers behind the loadbalancers automatically. for which it might read databags.
Where details of loadbalancers will be stored.

```bash
    knife mediawiki stack create --help
```

The above command will introduce you to this command in deep by letting you know all the flags it has.
The below an example of how to use it. It is better to know few aspects about this before using it.
If certain flags are not passed it will try to read the data from databag automatically which it should suppose to.
If it finds the valid data well and good else this is going to throw an error.

```bash
   knife mediawiki stack create --lbname 'test-lb' --wiki-network 'subnet-99axvjhjd' --mysql-network 'subnet-d81kfnd6'

   # we will break the parameters of above command to undeerstand it better
   # `--lbname` the name of the load balancer behind which the mediawiki servers has to be placed.
   # if you miss passinig this it will search for the appropriate databag for the info, if it dosen't finds
   # it will throw an error. flags `--wiki-network` and `--mysql-network` as the name specifies these are networks for mediawiki and mysql

```

#### Note

Every command here will try to store the data into databag once it is successfully created.


