class ContactPhone
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :phone, String

  belongs_to :phoneType

  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

end
