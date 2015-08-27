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

    def import(file)
      ActiveRecord::Base.transaction do
        name = file.original_filename.to_s.gsub(/(^.*(\\|\/))|(\.zip$)/, '')
        return false unless valid_report?(file)
        report = Report.create(:name => name, :internal_identifier => name.underscore)
        report.import(file)
      end
    end

    def valid_report?(file)
      valid = false
      Zip::ZipFile.open(file.path) do |zip|
        zip.sort.each do |entry|
          entry.name.split('/').each do |file|
            valid = true if REPORT_STRUCTURE.include?(file)
          end
        end
      end
      valid
    end
  end

  def root_dir
     @@root_dir ||= "#{Rails.root}/public"
  end

  def base_dir
    "#{root_dir}/compass_ae_reports/#{self.internal_identifier}"
  end

  def url
    "/public/compass_ae_reports/#{self.internal_identifier}"
  end


  def import(file)
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    file = ActionController::UploadedTempfile.new("uploaded-report").tap do |f|
      f.puts file.read
      f.original_filename = file.original_filename
      f.read # no idea why we need this here, otherwise the zip can't be opened
    end unless file.path

    Zip::ZipFile.open(file.path) do |zip|
      zip.each do |entry|
        if entry.name.split('/').last == 'base.html.erb'
          name = entry.name.sub(/__MACOSX\//, '')
          data = ''
          entry.get_input_stream { |io| data = io.read }
          self.template = data
          self.save
          file_support.update_file(self.template_path('base.html.erb'), data)
        else
          if entry.file?
            name = entry.name.sub(/__MACOSX\//, '')
            data = ''
            entry.get_input_stream { |io| data = io.read }
            data = StringIO.new(data) if data.present?
            report_file = self.files.where("name = ? and directory = ?", File.basename(name), File.join(self.url, File.dirname(name))).first
            unless report_file.nil?
              report_file.data = data
              report_file.save
            else
              self.add_file(data, File.join(file_support.root, self.url, name))
            end
          end
        end
      end
    end

  end

  def stylesheet_path(source)
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::Config.file_storage)
    File.join(file_support.root, self.url, 'stylesheets', source)
  end

  def image_path(source)
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::Config.file_storage)
    File.join(file_support.root, self.url, 'images', source)
  end

  def template_path(source)
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::Config.file_storage)
    File.join(file_support.root, self.url, 'templates', source)
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
"<%= bootstrap_load %>
<h3><%= title %></h3>

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