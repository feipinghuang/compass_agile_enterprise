ActiveRecord::Base.class_eval do
  def self.sanitize_order_params(sort, dir)
    self.sanitize_sql_array(['%s %s', sort, dir])
  end
end
