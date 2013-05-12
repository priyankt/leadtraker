class UserAffiliate
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :lender, 'User', :key => true
  belongs_to :agent, 'User', :key => true
  belongs_to :invite, 'UserInvitation', :key => true

end
