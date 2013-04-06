class Finance
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :gross, Float
  property :commission, Float
  property :net_commission, Float
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true
  
  has n, :financeExpenses
  
end
