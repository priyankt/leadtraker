class LeadUser
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :contacted, Boolean, :default => false
  property :status, Integer, :default => 1 # active = 1, inactive = 2, closed = 3
  property :contact_date, DateTime
  property :contract_date, DateTime
  property :closed_date, DateTime
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  has n, :notes
  has n, :appointments
  has 1, :finance
  
  belongs_to :user
  belongs_to :lead
  belongs_to :leadType
  belongs_to :contact
  belongs_to :leadSource

end
