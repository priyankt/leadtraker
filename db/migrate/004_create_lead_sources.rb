migration 4, :create_lead_sources do
  up do
    create_table :lead_sources do
      column :id, Integer, :serial => true
      column :name, String, :length => 255, :required => true
      column :description, Text
    end
  end

  down do
    drop_table :lead_sources
  end
end
