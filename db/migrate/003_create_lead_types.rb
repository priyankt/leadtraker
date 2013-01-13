migration 3, :create_lead_types do
  up do
    create_table :lead_types do
      column :id, Integer, :serial => true
      column :name, String, :length => 255, :required => true
      column :description, Text
    end
  end

  down do
    drop_table :lead_types
  end
end
