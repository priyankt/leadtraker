class Appointment
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :description, String
  property :title, String
  property :dttm, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

end
