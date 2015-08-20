class Report < ActiveRecord::Base
  attr_protected :created_at, :updated_at
  attr_accessible :name, :internal_identifier

  validates :name, :internal_identifier, :uniqueness => true

  before_create :set_default_template

  after_create :create_report_files!

  before_destroy :delete_report_files!

  has_file_assets

  REPORT_STRUCTURE = ['templates', 'stylesheets', 'images']

  class << self
    def iid(internal_identifier)
      find_by_internal_identifier(internal_identifier)
    end
  end

  def root_dir
    @@root_dir ||= "#{Rails.root}"
  end

  def base_dir
    "#{root_dir}/lib/rails_db_admin/reports/#{self.internal_identifier}"
  end

  def url
    "lib/rails_db_admin/reports/#{self.internal_identifier}"
  end

  def create_report_files!
    file_support = ErpTechSvcs::FileSupport::Base.new
    REPORT_STRUCTURE.each do |structure|
      Pathname.new(File.join("#{base_dir}/#{structure}")).tap do |dir|
        self.add_file(self.template,File.join(dir,"base.html.erb")) if structure == 'templates'
        FileUtils.mkdir_p(dir) unless dir.exist?
      end
    end
  end

  def delete_report_files!
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::Config.file_storage)
    file_support.delete_file(File.join(file_support.root, self.url), :force => true)
  end

  def set_default_template
    self.template =
"<h3><%= title %></h3>

<table>
  <tr>
  <% columns.each do |column| %>
    <th><%= column %></th>
  <% end %>
  </tr>
  <% rows.each do |row| %>
    <tr>
    <% row.values.each do |value| %>
	 <td><%= value %></td>
    <% end %>
    </tr>
  <% end %>
</table>

<%= report_download_link(unique_name, :csv, 'Download CSV') %> |
<%= report_download_link(unique_name, :pdf, 'Download PDF') %>"
  end
end