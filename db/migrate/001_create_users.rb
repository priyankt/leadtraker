migration 1, :create_users do
  up do
    create_table :users do
      column :id, Integer, :serial => true
      column :email, String, :format => :email_address, :required => true, :unique => true
	  column :salt, String
	  column :passwd, String, :required => true
	  column :first_name, String
	  column :last_name, String
	  column :phone, String
	  column :company, String
	  column :address, String
	  column :city, String
	  column :state, String
	  column :zip, String
	  column :created_on, DateTime
	  column :type , Integer, :required => true, :default => 1
	  column :user_key, String
    end
  end

  down do
    drop_table :users
  end
end