#resque_helper
require 'dotenv'
require 'active_support/core_ext'
require 'sinatra/activerecord'
require 'httparty'
require_relative 'models/model'
require 'pry'

Dotenv.load

module ResqueHelper
    
    def resque_update_prepaid_orders(params)
        puts "Doing background updating"
        puts "params received by resque = #{params.inspect}"
        recharge_change_header = params['recharge_change_header']
        
        
        my_start_time = Time.now
        my_update_orders = UpdatePrepaidOrder.where(is_updated: false)
        
        my_update_orders.each do |myorder|
            puts "Now fixing order_id #{myorder.order_id}"
            update_one_record(myorder.order_id, recharge_change_header)
            #sleep 6
            my_duration = (Time.now - my_start_time ).ceil
            puts "Been running #{my_duration}"
            if my_duration > 480
                puts "Ran 8 minutes, exiting"
                exit
            end

        end
        puts "All done with updating prepaid orders"

    end

    def update_one_record(order_id, recharge_change_header)
        puts "I am here"
        puts "recharge_change_header = #{recharge_change_header}"
        #myorder = Order.find_by_charge_id('26763015')
        myorder = UpdatePrepaidOrder.find_by_order_id(order_id.to_s)
        config_data = UpdatePrepaidConfig.first
        my_product_collection = config_data.product_collection
        puts myorder.inspect
        puts "-------------------"
        puts myorder.line_items.inspect
        my_line_items = myorder.line_items
        my_recharge_line_items = Hash.new
        my_subscription_id = 999
        my_line_items.each do |myline|
            puts "********"
            puts myline.inspect
            my_subscription_id = myline['subscription_id']
            my_properties = myline['properties']
            my_properties.each do |myp|
                puts myp.inspect
            end
            found_collection = false
            my_properties.map do |mystuff|
                # puts "#{key}, #{value}"
                if mystuff['name'] == 'product_collection'
                    mystuff['value'] = my_product_collection
                    found_collection = true
                end
            end
            if found_collection == false
                # only if I did not find the product_collection property in the line items do I need to add it
                puts "We are adding the product collection to the line item properties"
                my_properties << { "name" => "product_collection", "value" => my_product_collection }
            end
            puts "Now properties = #{my_properties.inspect}"
            puts "********"
            my_recharge_line_items = my_properties
        end

        if !my_subscription_id.nil?
            my_data = { "line_items" => [ { "properties" => my_recharge_line_items, "product_id" => config_data.product_id.to_i, "variant_id" => config_data.variant_id.to_i, "quantity" => 1, "title" => config_data.title, "subscription_id" => my_subscription_id }]}
        else
            my_data = { "line_items" => [ { "properties" => my_recharge_line_items, "product_id" => config_data.product_id.to_i, "variant_id" => config_data.variant_id.to_i, "quantity" => 1, "title" => config_data.title}]}
        end

        puts "Now here is what we are sending to Recharge"
        puts my_data.inspect
        #exit
        

        my_update_order = HTTParty.put("https://api.rechargeapps.com/orders/#{order_id}", :headers => recharge_change_header, :body => my_data.to_json, :timeout => 80)
        puts my_update_order.inspect

        if my_update_order.code == 200
            #puts "Im here"
            local_order = UpdatePrepaidOrder.find_by_order_id(order_id)
            local_order.is_updated = true
            time_updated = DateTime.now
            time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
            local_order.synced_at = time_updated_str
            local_order.save
            puts "Saving updated record"

        else
            puts "WE could not update the order order_id = #{order_id}"

        end

        

        
        
        

        


        
        

    end



end