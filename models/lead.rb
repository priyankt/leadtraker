class Lead
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :reference, String
  property :status, Integer

  #belongs_to :leadSource
  belongs_to :leadType
  
end
