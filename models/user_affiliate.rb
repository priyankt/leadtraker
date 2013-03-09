class UserAffiliate
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :lender, 'User', :key => true
  belongs_to :agent, 'User', :key => true

end
