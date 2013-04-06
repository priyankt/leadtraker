class StageDate
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :dttm, DateTime
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :lead
  belongs_to :leadStage
  
end
