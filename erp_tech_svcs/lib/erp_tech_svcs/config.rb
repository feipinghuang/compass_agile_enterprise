module ErpTechSvcs
  module Config
    class << self

      attr_accessor :max_file_size_in_mb,
                    :file_upload_types,
                    :installation_domain, 
                    :login_url,
                    :email_notifications_from, 
                    :email_regex,
                    :file_assets_location,
                    :file_protocol,
                    :s3_url_expires_in_seconds,
                    :s3_protocol,
                    :s3_url,
                    :file_storage,
                    :s3_cache_expires_in_minutes,
                    :session_expires_in_hours,
                    :notification_job_delay,
                    :default_time_zone

      def init!
        @defaults = {
          :@max_file_size_in_mb => 5,
          :@file_upload_types => 'txt,pdf,zip,tgz,gz,rar,jpg,jpeg,gif,png,tif,tiff,bmp,csv,xls,xlsx,doc,docx,ppt,pptx,psd,ai,css,js,mp3,mp4,m4a,m4v,mov,wav,wmv',
          :@installation_domain => 'localhost:3000',
          :@login_url => '/erp_app/login',
          :@email_notifications_from => 'notifications@noreply.com',
          :@email_regex => "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$",
          :@file_assets_location => 'file_assets', # relative to Rails.root/
          :@s3_url_expires_in_seconds => 60,
          :@s3_url => ':s3_path_url',
          :@file_protocol => 'http', # Can be either 'http' or 'https'
          :@s3_protocol => 'https', # Can be either 'http' or 'https'
          :@file_storage => :filesystem, # Can be either :s3 or :filesystem
          :@session_expires_in_hours => 12, # this is used by DeleteExpiredSessionsJob to purge inactive sessions from database
          :@notification_job_delay => '15 seconds from now',
          :@default_time_zone => 'Eastern Time (US & Canada)'
        }
      end

      def reset!
        @defaults.each do |k,v|
          instance_variable_set(k,v)
        end
      end

      def configure(&blk)
        @configure_blk = blk
      end

      def configure!
        @configure_blk.call(self) if @configure_blk
      end

      def installation_url
        "#{self.file_protocol}://#{self.installation_domain}"
      end

    end
    init!
    reset!
  end
end
