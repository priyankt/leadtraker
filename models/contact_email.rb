class ContactEmail
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :email, String, :format => :email_address
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :emailType

end
