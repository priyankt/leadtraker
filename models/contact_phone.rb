class ContactPhone
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :phone, String

  belongs_to :phoneType

  property :created_at, DateTime
  property :updated_at, DateTime

  before :save do |phone|
      puts phone.inspect
  end

end
