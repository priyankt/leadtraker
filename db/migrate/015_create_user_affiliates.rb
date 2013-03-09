migration 15, :create_user_affiliates do
  up do
    create_table :user_affiliates do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :user_affiliates
  end
end
