class LeadType
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true
  property :description, Text

  belongs_to :user
  
  has n, :leadSources
  has n, :leadStages

end
