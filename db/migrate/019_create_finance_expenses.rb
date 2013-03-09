migration 19, :create_finance_expenses do
  up do
    create_table :finance_expenses do
      column :id, Integer, :serial => true
      column :description, Text
      column :percent, Float
      column :value, Float
    end
  end

  down do
    drop_table :finance_expenses
  end
end
