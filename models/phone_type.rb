class PhoneType
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :unique => true
  property :created_at, DateTime
  property :updated_at, DateTime

  before :save do |phone_type|
      puts phone_type.inspect
  end

end
