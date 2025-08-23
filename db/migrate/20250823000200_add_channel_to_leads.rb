class AddChannelToLeads < ActiveRecord::Migration[6.1]
  def change
    add_column :leads, :canal, :string, default: "mock"
  end
end
