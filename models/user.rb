class User
  include DataMapper::Resource

property :id, Serial
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :salt, String
  property :passwd, String, :required => true
  property :name, String
  property :phone, String
  property :mobile, String
  property :company, String
  property :address, String
  property :city, String
  property :state, String
  property :zip, String
  property :type , Integer, :required => true
  property :share_contact, Boolean, :default => true
  property :created_at, DateTime
  property :updated_at, DateTime
  property :user_key, String

  # has n, :invitations, :child_key => [ :source_id ]
  # has n, :invites, self, :through => :invitations, :via => :target
  # user has multiple transaction types which we call lead types
  has n, :leadTypes
  has n, :contacts
  has n, :leadUsers
  has n, :leads, :through => :leadUsers
  has n, :leadSources

  has n, :userAffiliates, :child_key => [ :lender_id ]
  has n, :affiliates, self, :through => :userAffiliates, :via => :agent 

end
