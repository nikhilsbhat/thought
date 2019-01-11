require 'chef/knife'

module MediaWikiApp
  module MediawikiCommon

    def store_item_to_databag(data,item,refrence)
        if check_if_data_exists data
            if check_if_itme_exists data,refrence
                return false
            else
                create_databag_item data, item
                return true
            end
        else
            create_databag(data)
            create_databag_item data, item
            return true
        end
    end

    def delete_item_from_databag(data,item)
        if check_if_data_exists data
            if check_if_itme_exists data,item
                delete_databag_item data, item
                return true
            else
                return false
            end
        else
            return false
		end
    end

    def check_if_data_exists(resource)
        if Chef::DataBag.list.key?(resource)
            return true
        else
            return false
        end
    end

    def check_if_itme_exists(data,item)
        if check_if_data_exists data
            query = Chef::Search::Query.new
            query_value = query.search(:"#{data}", "id:#{item}")
            if query_value[2] == 1
                return true
            else
                return false
            end
        else
            return false
        end
    end

    def create_databag(data)
        data_bag = Chef::DataBag.new
        data_bag.name(data)
        data_bag.create
    end

    def delete_databag(data)
        data_bag = Chef::DataBag.new
        data_bag.name(data)
        data_bag.destroy
    end

    def create_databag_item(data,item)
       data_item = Chef::DataBagItem.new
       data_item.data_bag(data)
       data_item.raw_data = item  
       data_item.save
    end

    def delete_databag_item(data,item)
       data_item = Chef::DataBagItem.new 
       data_item.destroy(data, item)
    end

    def fetch_data(data_bag,databag_item,resource)
      data_item = Chef::DataBagItem.new
      data_item.data_bag(data_bag)
      data_value = Chef::DataBagItem.load(data_bag,databag_item)
      data_sg = data_value.raw_data["#{resource}"]
    end

  end
end
