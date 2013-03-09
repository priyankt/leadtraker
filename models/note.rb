class Note
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :text, String
  property :shared, Boolean
  property :created_at, DateTime
  property :updated_at, DateTime

end
