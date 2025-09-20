class AddChannelToLeads < ActiveRecord::Migration[7.1]
  def change
    add_column :leads, :channel, :string unless column_exists?(:leads, :channel)
  end
end
