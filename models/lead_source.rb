class LeadSource
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true
  property :description, Text

  has n, :leads

end
