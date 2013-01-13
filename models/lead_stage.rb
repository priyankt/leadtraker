class LeadStage
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :description, Text

  belongs_to :leadType
  has n, :leads
end
