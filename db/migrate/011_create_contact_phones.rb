migration 11, :create_contact_phones do
  up do
    create_table :contact_phones do
      column :id, Integer, :serial => true
      column :phone, String, :length => 255
    end
  end

  down do
    drop_table :contact_phones
  end
end
