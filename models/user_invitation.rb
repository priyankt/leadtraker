class UserInvitation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :from_user, String
  property :to_user, String
  property :status, Integer

  property :created_at, DateTime
  property :updated_at, DateTime

end
