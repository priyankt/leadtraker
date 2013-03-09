migration 7, :create_notes do
  up do
    create_table :notes do
      column :id, Integer, :serial => true
      column :text, String, :length => 255
    end
  end

  down do
    drop_table :notes
  end
end
