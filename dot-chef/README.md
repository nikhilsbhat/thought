# knife-mediawiki

A custom knife plugin which lets you perform certain action with MediWiki and MySql.

It helps in creating loadbalancer in AWS, storing its value in chef.
It helps in creating custom images using Packer, for this I have used [packer-config](https://github.com/ianchesal/packer-config)
this packer blend plugin help in creating custom image.


## Download

    Since a custom gem is not built for this yet, if one has to use this plugins
	then folder containing plugins has to be placed under '.chef/plugins/' as 'knife'

## Requires

    This requires hashicorp packer to be pre-installed, as per the [packer-config]("https://github.com/ianchesal/packer-config") 
	it should satisfy below condition.
* [Packer](https://packer.io) version 0.8.5 or higher

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

The above command will introduce you ino to this in deep by letting you know all the flags it has.
The below an example of how to use it. It is better to know few aspects about this before using it.
If certain flags are not passed it will try to read the data from databag automatically which it should suppose to.
If it finds the valid data well and good else this is going to throw an error.

#### Note

Every command here will try to store the data into databag once resource is successfully created.
This will be done to make sure that all created resources will be in tight coupled with chef.

```bash
    knife mediawiki stack create --lbname 'test-lb' --wiki-network 'subnet-99axvjhjd' --mysql-network 'subnet-d81kfnd6'
    # we will break the parameters of above command to undeerstand it better
    # --lbname the name of the load balancer behind which the mediawiki servers has to be placed.
    # if you miss passinig this it will search for the appropriate databag for the info, if it dosen't finds it will throw an error
    # flags --wiki-network and --mysql-network as the name specifies these are networks for mediawiki and mysql.
```

### knife mediawiki image create

```bash
    knife mediawiki image create (options)
```

This lets you create customized image in the required cloud, in the back this plugin uses tool Packer
in the form of 'packer-config' package.
Majority of the parameters has to be mentioned in knife.rb as well for this. This is because it will
read knife.rb if incase the parameter is not passed while invoking it.
Will be explained in deep as we move further.
With flag `--help` will let you know more about the plugin by elaborating about the flags it supports.

```bash
    knife mediawiki image create -r "role[test1]" -n "node-test" -e "_default" --packer_option "build" --region "ap-south-1"
	# -e specifies chef environment to which the image has to be tagged to.
	# -r specifies runlist which has to be attached to server while building customized image.
	# -n specifies nodename which will be used to register agianst chef (It is actually chef's node-name).
	# --packer_option this help us in performing action against packer it supports validate/build.
	# --region will decide in which region the image has to be created.
```

#### Note

Not just the parameters mentioned above is sufficient to build image, it requires more data.
For the same the plugin is designed to read the data from knife.rb if not passed.
Ex: ssh_name, key_name(name of keypair if cloud is aws), flavor and etc.
This plugin has a function to store the data of the image which it created using packer.
But because of the bug in the packer package I am unable to read the output.
Though the fucntion is tested and working as per the need, we are not using it.
The below sample show the databag structure which it is going to create.

```bash
	{
      "name": "data_bag_item_wikimedia_nodes",
      "json_class": "Chef::DataBagItem",
      "chef_type": "data_bag_item",
      "data_bag": "wikimedia",
      "raw_data": {
        "id": "nodes",
        "media-wiki-node-0": "ami-0cfe94a34ae968d0b",
        "media-wiki-node-1": "ami-0cfe94a34ae968d0b",
        "mysql-node-0": "ami-0a50d3614cf170f6d",
		     .          .
			 .          .
			 .          .
		<node-name>: <image-id> # this is a refrence for future addition as the 'knife image create' is called on
      }
    }
```

### knife mediawiki lb create

This helps one in creating network loadbalancers in aws (classic loadbalancer), and it will store its **details in databag** for future use

### knife mediawiki lb delete

This helps in deleting loadbalancers created by 'knife mediawiki lb create' and is also takes care of deregistering it from chef.
**Note, deregistering refers to cleaning its data stored in chef databag **

### knife mediawiki server create

Finally 'knife mediawiki stack create' will use this plugin/class to provision running/workinig chef-node in aws.
**Note, this does not use 'knife ec2' to provision servers rather it uses aws sdk**.
For more info on this refer the comments in the file itsef.
