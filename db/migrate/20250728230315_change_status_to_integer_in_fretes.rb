class ChangeStatusToIntegerInFretes < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TABLE fretes
      ALTER COLUMN status TYPE integer USING status::integer,
      ALTER COLUMN status SET DEFAULT 0;
    SQL
  end

  def down
    change_column :fretes, :status, :string
  end
end
