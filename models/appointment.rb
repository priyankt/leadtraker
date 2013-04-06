class Appointment
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :description, String
  property :title, String
  property :dttm, DateTime
  property :shared, Boolean
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

end
