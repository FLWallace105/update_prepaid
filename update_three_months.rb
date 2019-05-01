#update_three_months.rb
require 'dotenv'
Dotenv.load
require 'httparty'
require 'resque'
require 'active_record'
require "sinatra/activerecord"
require_relative 'models/model'
require_relative 'resque_helper'



module FixThreeMonths
    class ChangeThreeMonths

        def initialize
            Dotenv.load
            @apikey = ENV['ELLIE_API_KEY']
            @shopname = ENV['SHOPNAME']
            @password = ENV['ELLIE_PASSWORD']
            @recharge_access_token = ENV['RECHARGE_ACCESS_TOKEN']
            @my_header = {
                "X-Recharge-Access-Token" => @recharge_access_token
            }
            @my_change_charge_header = {
                "X-Recharge-Access-Token" => @recharge_access_token,
                "Accept" => "application/json",
                "Content-Type" =>"application/json"
            }

          end


        def load_table_update_prepaid_config
            
            UpdatePrepaidConfig.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('update_prepaid_config')

            CSV.foreach('may2019_update_prepaid_config.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
                # puts row.inspect
                title = row['title']
                product_id = row['product_id']
                variant_id = row['variant_id']
                product_collection = row['product_collection']
                new_update_prepaid_config = UpdatePrepaidConfig.new(title: title, product_id: product_id, variant_id: variant_id, product_collection: product_collection)
                new_update_prepaid_config.save
              end
            
        end

        def setup_update_prepaid_table
            
            
            UpdatePrepaidOrder.delete_all
            
            ActiveRecord::Base.connection.reset_pk_sequence!('update_prepaid')
            #SQL to get the prepaid that need to be updated every month
         

            #Below matches subs and orders
            # select subscriptions.customer_id, subscriptions.product_title, orders.scheduled_at, jsonb_array_elements(orders.line_items)->>'title' as title from subscriptions, orders where subscriptions.product_title = '3 MONTHS' and orders.scheduled_at > '2018-04-04' and orders.scheduled_at < '2018-05-01' and subscriptions.customer_id = orders.customer_id;



            #VIP 3 Month Box
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"VIP 3 Month Box\"}]' and status = 'QUEUED' and scheduled_at > '2018-10-01' and scheduled_at < '2018-10-01' "

            #ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #3 MONTHS
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"3 MONTHS\"}]' and status = 'QUEUED' and scheduled_at > '2018-07-04' and scheduled_at < '2018-08-01' "
            #ActiveRecord::Base.connection.execute(update_prepaid_sql)
            #Alternate take, just select is_prepaid = 1 which is order is prepaid
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where is_prepaid = 1 and status = 'QUEUED' and scheduled_at > '2018-07-04' and scheduled_at < '2018-08-01' "
            #ActiveRecord::Base.connection.execute(update_prepaid_sql)




            #VIP 3 Monthly Box
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"VIP 3 Monthly Box\"}]' and status = 'QUEUED' and scheduled_at > '2018-07-04' and scheduled_at < '2018-08-01' "
            #ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #ANY Prepaid
            my_end_month = Date.today.end_of_month
            my_end_month_str = my_end_month.strftime("%Y-%m-%d")
            puts "End of the month = #{my_end_month_str}"


            update_prepaid_sql = "insert into update_prepaid (order_id, transaction_id, charge_status, payment_processor, address_is_active, status, order_type, charge_id, address_id, shopify_id, shopify_order_id, shopify_cart_token, shipping_date, scheduled_at, shipped_date, processed_at, customer_id, first_name, last_name, is_prepaid, created_at, updated_at, email, line_items, total_price, shipping_address, billing_address, synced_at) select order_id, transaction_id, charge_status, payment_processor, address_is_active, status, order_type, charge_id, address_id, shopify_id, shopify_order_id, shopify_cart_token, shipping_date, scheduled_at, shipped_date, processed_at, customer_id, first_name, last_name, is_prepaid, created_at, updated_at, email, line_items, total_price, shipping_address, billing_address, synced_at from orders where is_prepaid = '1'  and scheduled_at > \'#{my_end_month_str}\' and scheduled_at < '2019-06-01' and status = \'QUEUED\' "
            ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #ONLY the 3 Months 3 Items prepaid
            update_prepaid_sql_3items = "insert into update_prepaid (order_id, transaction_id, charge_status, payment_processor, address_is_active, status, order_type, charge_id, address_id, shopify_id, shopify_order_id, shopify_cart_token, shipping_date, scheduled_at, shipped_date, processed_at, customer_id, first_name, last_name, is_prepaid, created_at, updated_at, email, line_items, total_price, shipping_address, billing_address, synced_at) select order_id, transaction_id, charge_status, payment_processor, address_is_active, status, order_type, charge_id, address_id, shopify_id, shopify_order_id, shopify_cart_token, shipping_date, scheduled_at, shipped_date, processed_at, customer_id, first_name, last_name, is_prepaid, created_at, updated_at, email, line_items, total_price, shipping_address, billing_address, synced_at from orders where is_prepaid = '1'  and scheduled_at > '2018-12-31' and scheduled_at < '2019-02-01' and line_items  @> '[{\"title\":\"3 Months - 3 Items\"}]'"
            #ActiveRecord::Base.connection.execute(update_prepaid_sql_3items)




            #In The Zone - 5 Items
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"In The Zone - 5 Items\"}]' and status = 'QUEUED' and scheduled_at > '2018-05-31' and scheduled_at < '2018-07-01' "
            #ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #Set The Pace - 5 Items
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"Set The Pace - 5 Items\"}]' and status = 'QUEUED' and scheduled_at > '2018-05-31' and scheduled_at < '2018-07-01' "
            #ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #After Dark - 5 Item
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"After Dark - 5 Item\"}]' and status = 'QUEUED' and scheduled_at > '2018-05-31' and scheduled_at < '2018-07-01' "
            #ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #Desert Sage - 5 Item
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"Desert Sage - 5 Item\"}]' and status = 'QUEUED' and scheduled_at > '2018-05-31' and scheduled_at < '2018-07-01' "
            #ActiveRecord::Base.connection.execute(update_prepaid_sql)


            

        end

        def update_prepaid_orders
            my_start_time = Time.now
            my_update_orders = UpdatePrepaidOrder.where(is_updated: false)
            my_update_orders.each do |myorder|
                puts "Now fixing order_id #{myorder.order_id}"
                update_one_record(myorder.order_id)
                sleep 6
                my_duration = (Time.now - my_start_time ).ceil
                puts "Been running #{my_duration}"
                if my_duration > 480
                    puts "Ran 8 minutes, exiting"
                    exit
                end

            end


        end

        def background_update_prepaid_orders
            params = { "recharge_change_header" => @my_change_charge_header }
            #puts params.inspect
            Resque.enqueue(UpdatePrepaid, params) 
        end

        class UpdatePrepaid
            extend ResqueHelper
            @queue = "update_prepaid_orders"    
            def self.perform(params)
              puts "Starting job"
              #puts "here params are #{params.inspect}"
              resque_update_prepaid_orders(params)
            end
          end


        def examine_order(order_id)
            #GET /orders/<order_id>
            my_order = HTTParty.get("https://api.rechargeapps.com/orders/#{order_id}", :headers => @my_header,  :timeout => 80)
            puts my_order.inspect
            puts "--------------------"
            order_info = my_order.parsed_response['order']
            puts order_info.inspect
            puts "**********************"
            temp_hash = Hash.new
            order_info.each do |myinf|
                #puts myinf.inspect
                #puts myinf.class
                temp_hash = {myinf[0] => myinf[1]}
                puts temp_hash

            end

        end

        def update_line_items_order(order_id)
            #PUT /orders/<order_id>
            my_data = { "line_items" => [{"price"=>"0.00", "product_title"=>"3 MONTHS", "properties"=>[{"name"=>"charge_interval_frequency", "value"=>"3"}, {"name"=>"charge_interval_unit_type", "value"=>"Months"}, {"name"=>"leggings", "value"=>"L"}, {"name"=>"main-product", "value"=>"true"}, {"name"=>"product_collection", "value"=>"Love and Light - 5 Items"}, {"name"=>"product_id", "value"=>"1401706971187"}, {"name"=>"referrer", "value"=>""}, {"name"=>"shipping_interval_frequency", "value"=>"1"}, {"name"=>"shipping_interval_unit_type", "value"=>"Months"}, {"name"=>"sports-bra", "value"=>"S"}, {"name"=>"tops", "value"=>"L"}], "quantity"=>1, "shopify_product_id"=>"614485950496", "shopify_variant_id"=>"6348348620832", "sku"=>"722457572908", "subscription_id"=>22093657, "title"=>"3 MONTHS", "variant_title"=>""}]}
            body = my_data.to_json
            
            
            
            my_order = HTTParty.get("https://api.rechargeapps.com/orders/#{order_id}", :headers => @my_change_charge_header, :body => body,  :timeout => 80)
            puts my_order.inspect

        end


        def update_one_record(order_id)
            #myorder = Order.find_by_charge_id('26763015')
            myorder = Order.find_by_order_id(order_id.to_s)
            #puts myorder.inspect
            #puts "-------------------"
            puts myorder.line_items.inspect

            my_line_items = myorder.line_items[0]['properties']
            found_sports_jacket = false
            tops_size = ""
            found_collection = false
            #my_product_collection = 'Desert Sage - 5 Item'
            my_title = myorder.line_items[0]['title']
            puts my_title
            #if my_title == "3 MONTHS"
            #    puts "not processing"
            #    return

            #end

            #temp fix Steel the Show 

            if my_title != "Starstruck - 5 ITEMS"

            config_data = UpdatePrepaidConfig.find_by_title(my_title)
            puts config_data.inspect
            my_product_collection = config_data.product_collection
            puts my_product_collection.inspect

            else
                #[{"sku"=>"722457572908", "price"=>"0.00", "title"=>"3 MONTHS", "quantity"=>1, "properties"=>[{"name"=>"accessories", "value"=>"ONE SIZE"}, {"name"=>"charge_interval_frequency", "value"=>"3"}, {"name"=>"charge_interval_unit_type", "value"=>"Months"}, {"name"=>"equipment", "value"=>"ONE SIZE"}, {"name"=>"leggings", "value"=>"M"}, {"name"=>"main-product", "value"=>"true"}, {"name"=>"recurring_price", "value"=>"149.85"}, {"name"=>"shipping_interval_frequency", "value"=>"1"}, {"name"=>"shipping_interval_unit_type", "value"=>"Months"}, {"name"=>"sports-bra", "value"=>"M"}, {"name"=>"tops", "value"=>"S"}, {"name"=>"sports-jacket", "value"=>"M"}, {"name"=>"product_collection", "value"=>"Fierce & Floral - 5 Items"}, {"name"=>"unique_identifier", "value"=>"7dfd7bd9-5e61-424b-92e7-cb476852bec9"}], "product_title"=>"3 MONTHS", "variant_title"=>"", "subscription_id"=>5800309, "shopify_product_id"=>"23729012754", "shopify_variant_id"=>"177939546130"}]
                my_title = "3 MONTHS"
                config_data = UpdatePrepaidConfig.find_by_title(my_title)
                puts config_data.inspect
                my_product_collection = config_data.product_collection
                puts my_product_collection.inspect


            end

            



            
            my_index = 0
            #Add stuff 3/30 check for missing top or bra size use legging
            #check for missing glove size use legging
            found_top = false
            found_bra = false
            found_glove = false
            found_leggings = false
            #tops_size = ""
            bra_size = ""
            glove_size = ""
            leggings_size = ""


            my_line_items.map do |mystuff|
                # puts "#{key}, #{value}"
                if mystuff['name'] == 'product_collection'
                    mystuff['value'] = my_product_collection
                    found_collection = true
                end
                if mystuff['name'] == "sports-jacket"
                    found_sports_jacket = true
                end
                if mystuff['name'] == "tops"
                    tops_size = mystuff['value']
                    found_top = true
                    #puts "ATTENTION -- Sports BRa SIZE = #{sports_bra_size}"
                end
                #if mystuff['name'] == "gloves"
                #    found_glove = true
                #end
                if mystuff['name'] == "sports-bra"
                    found_bra = true
                end
                if mystuff['name'] == "leggings"
                    found_leggings = true
                    leggings_size = mystuff['value']
                end

                if mystuff['name'] == "gloves"
                    my_line_items.delete_at(my_index)

                end
                my_index += 1

            end
            
            if found_collection == false
                # only if I did not find the product_collection property in the line items do I need to add it
                puts "We are adding the product collection to the line item properties"
                my_line_items << { "name" => "product_collection", "value" => my_product_collection }
            end

            if found_sports_jacket == false
                puts "We are adding the sports-bra size for the sports-jacket size"
                my_line_items << { "name" => "sports-jacket", "value" => tops_size}
            end

            #Stuff things in my_line_items if no bra size, no top size, no glove size
            #if found_glove == false
            #    if leggings_size == "XS" || leggings_size == "S"
            #        glove_size = "S"
            #    elsif leggings_size == "M" || leggings_size == "L"
            #        glove_size = "M"
            #    elsif leggings_size == "XL"
            #        glove_size = "L"
            #    else
            #        puts "Can't find any glove size assigning to medium"
            #        glove_size = "M"
            #    end
            #    my_line_items << { "name" => "gloves", "value" => glove_size}

            #end

            if found_top == false
                #assign legging size
                my_line_items << {"name" => "tops", "value" => leggings_size }

            end

            if found_bra == false
                #assign legging size
                my_line_items << {"name" => "sports-bra", "value" => leggings_size }

            end



            puts "my_line_items = #{my_line_items.inspect}"
            #puts "Exiting"
            #exit

            #local_title = ""
            #local_product_id = 999
            #local_variant_id = 999
            #my_stuff = myorder.line_items
            #my_stuff.each do |funky|
            #    puts funky.inspect
            #    local_title = funky['title']
            #    local_product_id = funky['shopify_product_id']
            #    local_variant_id = funky['shopify_variant_id']
            #end
            #puts local_title, local_product_id, local_variant_id
            
            #if local_title == '3 MONTHS'
            #    local_title = config_data.title
            #    local_product_id = config_data.product_id.to_i
            #    local_variant_id = config_data.variant_id.to_i

            #end

            #if local_title == '3 Months - 5 Items'
            #    local_title = '3 Months - 5 Items'
            #    local_product_id = 2209789771834
            #    local_variant_id = 22212763320378

            #end

            #if local_title == '3 Months - 3 Items'
            #    local_title = '3 Months - 3 Items'
            #    local_product_id = 2209786298426
            #    local_variant_id = 22212749393978

            #end
            puts myorder.line_items.inspect
            fixed_order = Array.new
            fixed_order = myorder.line_items
            #Add Recharge required stuff
            fixed_order[0]['product_id'] = config_data.product_id.to_i
            fixed_order[0]['variant_id'] = config_data.variant_id.to_i
            fixed_order[0]['quantity'] = 1
            fixed_order[0]['title'] = config_data.title

            #remove shopify_variant_id:
            
            fixed_order[0].tap {|myh| myh.delete('shopify_variant_id')}
            fixed_order[0].tap {|myh| myh.delete('shopify_product_id')}
            fixed_order[0].tap {|myh| myh.delete('images')}
            


            puts fixed_order.inspect
            #exit
            
            my_order_id = myorder.order_id
            #NOPE -- only changing line items product_collection now
            #my_data = { "line_items" => [ { "properties" => my_line_items, "product_id" => config_data.product_id.to_i, "variant_id" => config_data.variant_id.to_i, "quantity" => 1, "title" => config_data.title}]}



            #my_data = { "line_items" => [ { "properties" => my_line_items }]}
            my_data = { "line_items" => fixed_order }


            puts "Now here is what we are sending to Recharge"
            puts my_data.inspect
            puts "----------"
            #puts JSON.pretty_generate(my_data)
            #exit


            my_update_order = HTTParty.put("https://api.rechargeapps.com/orders/#{my_order_id}", :headers => @my_change_charge_header, :body => my_data.to_json, :timeout => 80)
            puts my_update_order.inspect

            if my_update_order.code == 200
                local_order = UpdatePrepaidOrder.find_by_order_id(my_order_id)
                local_order.is_updated = true
                time_updated = DateTime.now
                time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
                local_order.updated_at = time_updated_str
                local_order.save

            else
                puts "WE could not update the order order_id = #{my_order_id}"

            end
            #exit

        end

        
    end
end