class FinanceExpense
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :description, Text
  property :percent, Float
  property :value, Float
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :finance

end
