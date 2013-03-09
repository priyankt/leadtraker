class ContactPhone
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :phone, String

  belongs_to :contact
  belongs_to :phoneType

  property :created_at, DateTime
  property :updated_at, DateTime


end
