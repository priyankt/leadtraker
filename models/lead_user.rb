class LeadUser
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :contacted, Boolean
  property :status, Integer
  property :contact_date, Date
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :notes
  has n, :appointments
  
  belongs_to :user
  belongs_to :lead
  belongs_to :leadType
  belongs_to :contact

end
