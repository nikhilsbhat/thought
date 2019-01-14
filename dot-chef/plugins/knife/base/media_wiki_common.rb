require 'chef/knife'

module MediaWikiApp
  module MediawikiCommon

    def store_item_to_databag(data,item,refrence)
        if check_if_data_exists data
            if check_if_item_exists data,refrence
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
            if check_if_item_exists data,item
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

    def check_if_item_exists(data,item)
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

    def check_if_particular_item_exists(data,item,value)
      data_value = Chef::DataBagItem.load(data,item)
      if (data_value.raw_data["#{value}"].inspect) == "nil"
        return false
      else
        return true
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

    def fetch_raw_data(data_bag,databag_item,raw_item)
      data_item = Chef::DataBagItem.new
      data_item.data_bag(data_bag)
      data_value = Chef::DataBagItem.load(data_bag,databag_item)
      ((data_value.raw_data).to_hash).each do |key,value|
        if key == raw_item
          return value
        end
      end
      return nil
    end

    # please do know that this works only if rawdata is of type array.
    def append_raw_data(data_bag,databag_item,raw_item,value)
      data_item = Chef::DataBagItem.new
      data_item.data_bag(data_bag)
      data_value = Chef::DataBagItem.load(data_bag,databag_item)
      ((data_value.raw_data).to_hash).each do |k,v|
        if k == raw_item
          v.push(value)
          data_value.save
          return true
        end
      end
      return false
    end

    def add_raw_data(data_bag,databag_item,raw_item,data)
      data_value = Chef::DataBagItem.load(data_bag,databag_item)

      data_item = Chef::DataBagItem.new
      data_item.data_bag(data_bag)
      data_item.raw_data = ((data_value.raw_data).to_hash).merge(data)  
      data_item.save
      return true
    end

  end
end
