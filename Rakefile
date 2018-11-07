require 'dotenv'
Dotenv.load
require 'active_record'
require 'resque'
require 'resque/tasks'
require 'sinatra/activerecord/rake'
require_relative 'update_three_months'


namespace :order_update do
desc 'Fix a Three Month Order'
task :fix_order, :order_id do |t, args|
    order_id = args['order_id']
    FixThreeMonths::ChangeThreeMonths.new.update_one_record(order_id)
end



desc 'load configuration csv update_prepaid_config.csv'
task :load_csv_configuration do |t|
    FixThreeMonths::ChangeThreeMonths.new.load_table_update_prepaid_config
end

desc 'Set up the update_prepaid table'
task :update_prepaid do |t|
    FixThreeMonths::ChangeThreeMonths.new.setup_update_prepaid_table
end

desc 'Update all prepaid orders'
task :update_all_prepaid do |t|
    FixThreeMonths::ChangeThreeMonths.new.update_prepaid_orders
end

desc 'Update all prepaid orders in background task'
task :background_all_prepaid do |t|
    FixThreeMonths::ChangeThreeMonths.new.background_update_prepaid_orders
end

desc 'Examine a specific order'
task :examine_single_order, :order_id do |t, args|
    order_id = args['order_id']
    FixThreeMonths::ChangeThreeMonths.new.examine_order(order_id)
end


desc 'Update a specfic order non background'
task :update_specific_order, :order_id do |t, args|
    order_id = args['order_id']
    FixThreeMonths::ChangeThreeMonths.new.update_line_items_order(order_id)
end

end