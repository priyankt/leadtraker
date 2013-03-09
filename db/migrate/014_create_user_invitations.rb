migration 14, :create_user_invitations do
  up do
    create_table :user_invitations do
      column :id, Integer, :serial => true
      column :from_user, String, :length => 255
      column :to_user, String, :length => 255
      column :status, Integer
    end
  end

  down do
    drop_table :user_invitations
  end
end
