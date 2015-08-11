class UpdateWorkEffortForProdV1 < ActiveRecord::Migration
  def change
    add_column :work_efforts, :comments_text, :text unless column_exists? :work_efforts, :comments_text
  end
end
