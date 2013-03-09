migration 17, :create_stage_dates do
  up do
    create_table :stage_dates do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :stage_dates
  end
end
