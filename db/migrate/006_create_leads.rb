migration 6, :create_leads do
  up do
    create_table :leads do
      column :id, Integer, :serial => true
      column :reference, String, :length => 255
      column :status, Integer
    end
  end

  down do
    drop_table :leads
  end
end
