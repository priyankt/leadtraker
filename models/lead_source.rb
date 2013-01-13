class LeadSource
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true
  property :description, Text

  belongs_to :leadType
  has n, :leads

end
