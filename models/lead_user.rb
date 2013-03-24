class LeadUser
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :contacted, Boolean
  property :status, Integer, :default => 1 # default active
  property :contact_date, DateTime
  property :contract_date, DateTime
  property :closed_date, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :notes
  has n, :appointments
  has 1, :finance
  
  belongs_to :user
  belongs_to :lead
  belongs_to :leadType
  belongs_to :contact
  belongs_to :leadSource

end
