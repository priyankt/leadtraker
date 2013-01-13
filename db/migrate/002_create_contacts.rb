migration 2, :create_contacts do
  up do
    create_table :contacts do
      column :id, Integer, :serial => true
      column :first_name, String, :length => 255
      column :last_name, String, :length => 255
      column :primary_email, String, :length => 255, :required => true, :format => :email_address
      column :secondary_email, String, :length => 255, :format => :email_address
      column :phone_direct, String, :length => 255
      column :phone_mobile, String, :length => 255
      column :phone_home, String, :length => 255
      column :company, String, :length => 255
      column :title, String, :length => 255
    end
  end

  down do
    drop_table :contacts
  end
end
