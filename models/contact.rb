class Contact
  include DataMapper::Resource

  property :id, Serial
  property :first_name, String
  property :last_name, String
  property :primary_email, String, :format => :email_address, :required => true
  property :secondary_email, String
  property :phone_direct, String
  property :phone_mobile, String
  property :phone_home, String
  property :company, String
  property :title, String

  belongs_to :lead

end
