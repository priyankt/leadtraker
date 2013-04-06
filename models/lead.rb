class Lead
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  #property :lead_name, String
  property :prop_address, String
  property :prop_city, String
  property :prop_state, String
  property :prop_zip, String
  property :reference, String
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  has n, :leadUsers
  has n, :users, :through => :leadUsers

  has n, :stageDates
  has n, :leadStages, :through => :stageDates
  
end
