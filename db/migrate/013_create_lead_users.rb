migration 13, :create_lead_users do
  up do
    create_table :lead_users do
      column :id, Integer, :serial => true
      column :contacted, Boolean
      column :status, Integer
      column :contact_date, Date
    end
  end

  down do
    drop_table :lead_users
  end
end
