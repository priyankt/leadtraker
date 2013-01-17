class User
  include DataMapper::Resource

property :id, Serial
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :salt, String
  property :passwd, String, :required => true
  property :first_name, String
  property :last_name, String
  property :phone, String
  property :company, String
  property :address, String
  property :city, String
  property :state, String
  property :zip, String
  property :created_on, DateTime
  property :type , Integer, :required => true
  property :user_key, String
 
  # has n, :invitations, :child_key => [ :source_id ]
  # has n, :invites, self, :through => :invitations, :via => :target
  # user has multiple transaction types which we call lead types
  has n, :leadTypes
  has n, :contacts

end
