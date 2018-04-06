#update_three_months.rb
require 'dotenv'
Dotenv.load
require 'httparty'
require 'resque'
require 'active_record'
require "sinatra/activerecord"
require_relative 'models/model'



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

        def setup_update_prepaid_table
            UpdatePrepaid.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('update_prepaid')
            #SQL to get the prepaid that need to be updated every month


            #Below matches subs and orders
            # select subscriptions.customer_id, subscriptions.product_title, orders.scheduled_at, jsonb_array_elements(orders.line_items)->>'title' as title from subscriptions, orders where subscriptions.product_title = '3 MONTHS' and orders.scheduled_at > '2018-04-04' and orders.scheduled_at < '2018-05-01' and subscriptions.customer_id = orders.customer_id;



            #VIP 3 Month Box
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"VIP 3 Month Box\"}]' and status = 'QUEUED' and scheduled_at > '2018-04-03' and scheduled_at < '2018-05-01' "

            ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #3 MONTHS
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"3 MONTHS\"}]' and status = 'QUEUED' and scheduled_at > '2018-04-03' and scheduled_at < '2018-05-01' "
            ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #VIP 3 Monthly Box
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"VIP 3 Monthly Box\"}]' and status = 'QUEUED' and scheduled_at > '2018-04-05' and scheduled_at < '2018-05-01' "
            ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #All Star
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"All Star - 5 Items\"}]' and status = 'QUEUED' and scheduled_at > '2018-04-05' and scheduled_at < '2018-05-01' "
            ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #In The Zone - 5 Items
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"In The Zone - 5 Items\"}]' and status = 'QUEUED' and scheduled_at > '2018-04-05' and scheduled_at < '2018-05-01' "
            ActiveRecord::Base.connection.execute(update_prepaid_sql)

            #Set The Pace - 5 Items
            update_prepaid_sql = "insert into update_prepaid (customer_id, order_id, title, scheduled_at, properties) select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{\"title\":\"Set The Pace - 5 Items\"}]' and status = 'QUEUED' and scheduled_at > '2018-04-05' and scheduled_at < '2018-05-01' "
            ActiveRecord::Base.connection.execute(update_prepaid_sql)

            

        end

        def update_prepaid_orders
            my_start_time = Time.now
            my_update_orders = UpdatePrepaid.where(is_updated: false)
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




        def update_one_record(order_id)
            #myorder = Order.find_by_charge_id('26763015')
            myorder = Order.find_by_order_id(order_id.to_s)
            #puts myorder.inspect
            #puts "-------------------"
            puts myorder.line_items.inspect

            my_line_items = myorder.line_items[0]['properties']

            found_collection = false
            my_product_collection = 'Desert Sage - 5 Item'

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


            #PUT /orders/<order_id>
            #url = "https://api.rechargeapps.com/orders/34974433"
#data ={
#   "line_items":[{
#        "price":4,
#        "properties":{},
#        "quantity":12,
#        "product_id":7743068934,
#        "variant_id":42924741205, 
#        "title":"Test"
#   }]
#}
#select customer_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{"title":"VIP 3 Month Box"}]' and status = 'QUEUED' and scheduled_at > '2018-04-3' and scheduled_at < '2018-05-01';
#select customer_id, order_id, jsonb_array_elements(line_items)->>'title' as title, scheduled_at, jsonb_array_elements(line_items)->>'properties' from orders where line_items  @> '[{"title":"VIP 3 Month Box"}]' and status = 'QUEUED' and scheduled_at > '2018-04-3' and scheduled_at < '2018-05-01';

#"quantity": 1,
#"shopify_product_id": "6032558662",
#"shopify_variant_id": "19099995014",
#"subscription_id": 11957808,
#"title": "testing discount  Auto renew",
            my_order_id = myorder.order_id
            my_data = { "line_items" => [ { "properties" => my_line_items, "product_id" => 197983830034, "variant_id" => 1788451618834, "quantity" => 1, "title" => "Desert Sage - 5 Item"}]}

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