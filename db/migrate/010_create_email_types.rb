migration 10, :create_email_types do
  up do
    create_table :email_types do
      column :id, Integer, :serial => true
      column :name, String, :length => 255
    end
  end

  down do
    drop_table :email_types
  end
end
