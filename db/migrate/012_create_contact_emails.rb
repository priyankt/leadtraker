migration 12, :create_contact_emails do
  up do
    create_table :contact_emails do
      column :id, Integer, :serial => true
      column :email, String, :length => 255
    end
  end

  down do
    drop_table :contact_emails
  end
end
