class RenameUpsertColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :amr_data_feed_import_logs, :records_upserted, :records_updated
  end
end
