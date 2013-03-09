migration 16, :create_appointments do
  up do
    create_table :appointments do
      column :id, Integer, :serial => true
      column :description, String, :length => 255
      column :title, String, :length => 255
    end
  end

  down do
    drop_table :appointments
  end
end
