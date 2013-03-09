class Finance
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :gross, Float
  property :commission, Float
  property :net_commission, Float
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :financeExpense
  belongs_to :leadUser

end
