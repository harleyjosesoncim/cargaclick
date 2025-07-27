class CreateModals < ActiveRecord::Migration[7.1]
  def change
    create_table :modals do |t|
      t.string :nome

      t.timestamps
    end
  end
end
