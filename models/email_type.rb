class EmailType
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :unique => true
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

end
