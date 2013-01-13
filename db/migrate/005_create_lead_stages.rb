migration 5, :create_lead_stages do
  up do
    create_table :lead_stages do
      column :id, Integer, :serial => true
      column :name, String, :length => 255
      column :description, Text
    end
  end

  down do
    drop_table :lead_stages
  end
end
