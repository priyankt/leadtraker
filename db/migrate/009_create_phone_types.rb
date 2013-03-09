migration 9, :create_phone_types do
  up do
    create_table :phone_types do
      column :id, Integer, :serial => true
      column :name, String, :length => 255
    end
  end

  down do
    drop_table :phone_types
  end
end
