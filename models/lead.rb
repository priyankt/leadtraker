class Lead
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :reference, String
  property :status, Integer

  belongs_to :contact
  #belongs_to :leadSource
  #has 1, :leadType, {:through => DataMapper::Resource}
  
end
