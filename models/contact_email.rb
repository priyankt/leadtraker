class ContactEmail
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :email, String, :format => :email_address
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :emailType

end
