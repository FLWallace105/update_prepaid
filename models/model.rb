class SubscriptionsUpdated < ActiveRecord::Base
  self.table_name = "subscriptions_updated"
end

class Charge < ActiveRecord::Base

end

class Order < ActiveRecord::Base

end

class UpdatePrepaidOrder < ActiveRecord::Base
  self.table_name = "update_prepaid"
end

class FunkyStuff < ActiveRecord::Base
  self.table_name = "update_prepaid"
end

class UpdatePrepaidConfig < ActiveRecord::Base
  self.table_name =  "update_prepaid_config"
end