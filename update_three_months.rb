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

            CSV.foreach('november_update_prepaid_config.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
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
            update_prepaid_sql = "insert into update_prepaid (order_id, transaction_id, charge_status, payment_processor, address_is_active, status, order_type, charge_id, address_id, shopify_id, shopify_order_id, shopify_cart_token, shipping_date, scheduled_at, shipped_date, processed_at, customer_id, first_name, last_name, is_prepaid, created_at, updated_at, email, line_items, total_price, shipping_address, billing_address, synced_at) select order_id, transaction_id, charge_status, payment_processor, address_is_active, status, order_type, charge_id, address_id, shopify_id, shopify_order_id, shopify_cart_token, shipping_date, scheduled_at, shipped_date, processed_at, customer_id, first_name, last_name, is_prepaid, created_at, updated_at, email, line_items, total_price, shipping_address, billing_address, synced_at from orders where is_prepaid = '1'  and scheduled_at > '2018-11-01' and scheduled_at < '2018-12-01' "
            ActiveRecord::Base.connection.execute(update_prepaid_sql)

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

            found_collection = false
            #my_product_collection = 'Desert Sage - 5 Item'
            config_data = UpdatePrepaidConfig.first
            my_product_collection = config_data.product_collection

            my_line_items.map do |mystuff|
                # puts "#{key}, #{value}"
                if mystuff['name'] == 'product_collection'
                    mystuff['value'] = my_product_collection
                    found_collection = true
                end
            end
            
            if found_collection == false
                # only if I did not find the product_collection property in the line items do I need to add it
                puts "We are adding the product collection to the line item properties"
                my_line_items << { "name" => "product_collection", "value" => my_product_collection }
            end

            puts "my_line_items = #{my_line_items.inspect}"


            
            my_order_id = myorder.order_id
            #NOPE -- only changing line items product_collection now
            my_data = { "line_items" => [ { "properties" => my_line_items, "product_id" => config_data.product_id.to_i, "variant_id" => config_data.variant_id.to_i, "quantity" => 1, "title" => config_data.title}]}
            #my_data = { "line_items" => [ { "properties" => my_line_items }]}


            puts "Now here is what we are sending to Recharge"
            puts my_data.inspect
            


            my_update_order = HTTParty.put("https://api.rechargeapps.com/orders/#{my_order_id}", :headers => @my_change_charge_header, :body => my_data.to_json, :timeout => 80)
            puts my_update_order.inspect

            if my_update_order.code == 200
                local_order = UpdatePrepaid.find_by_order_id(my_order_id)
                local_order.is_updated = true
                time_updated = DateTime.now
                time_updated_str = time_updated.strftime("%Y-%m-%d %H:%M:%S")
                local_order.updated_at = time_updated_str
                local_order.save

            else
                puts "WE could not update the order order_id = #{my_order_id}"

            end

        end

        
    end
end