class FinanceExpense
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :description, Text
  property :percent, Float
  property :value, Float
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :finance

end
