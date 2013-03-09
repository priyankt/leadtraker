migration 18, :create_finances do
  up do
    create_table :finances do
      column :id, Integer, :serial => true
      column :gross, Float
      column :commission, Float
      column :net_commission, Float
    end
  end

  down do
    drop_table :finances
  end
end
