class Contact
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :company, String
  property :title, String
  property :address, String
  property :city, String
  property :state, String
  property :zipcode, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  has n, :contactPhones
  has n, :contactEmails

  #belongs_to :user

end
