class AddNewCalendarFields < ActiveRecord::Migration[5.1]
  def change
    add_column    :calendars, :based_on_id,       :integer, index: true
    add_column    :calendars, :calendar_area_id,  :integer, index: true
    add_column    :calendars, :template,          :boolean, default: false
    rename_column :calendars, :name, :title
  end
end
