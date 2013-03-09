class LeadType
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true
  property :description, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user
  
  has n, :leadStages

end
