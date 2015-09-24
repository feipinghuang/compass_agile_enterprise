#ErpTechSvcs

This engine is implemented with the premise that services like logging, tracing and encryption would likely already exist in many organizations, so they are factored here so they can easily be re-implemented. There are default implementations here, and we track several excellent Rails projects as potential implementations of services like security and content/digital asset mgt.

##Initializer Options

- installation\_domain
  - The domain that your Compass AE instance is installed at.
  - Default : 'localhost:3000'
- login\_url
  - Path to the login page.
  - Default : '/erp_app/login'
- email\_notifications\_from
  - From address for email notifications.
  - Default : 'notifications@noreply.com'
- email_regex
  - Email validation regex
  - Default : ^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$
- max\_file\_size\_in\_mb
  - Max allowed file upload size in mega bytes.
  - Default : 5
- file_upload_types
  - Allowed file upload types
  - Default : 'txt,pdf,zip,tgz,gz,rar,jpg,jpeg,gif,png,tif,tiff,bmp,csv,xls,xlsx,doc,docx,ppt,pptx,psd,ai,css,js,mp3,mp4,m4a,m4v,mov,wav,wmv'
- file\_assets\_location
  - Where you want file_assets to be saved to.
  - Default : file_assets
- file\_storage
  - File storage to use either s3 or filesystem.
  - Default : :filesystem
- file\_protocol
  - Protocol for file urls
  - Default : http
- s3\_url\_expires\_in_seconds
  - Set expiration in seconds on an S3 url to a secure file
  - Default : 60
- s3\_protocol
  - Protocol for S3 URLs
  - Default : https
- session\_expires\_in_hours
  - Used by DeleteExpiredSessionsJob to purge inaactive sessions from database.
  - Default : 12
- compass\_logger\_path
  - Default : Rails.root/log

### Override Initializer

To override these settings simple create a erp_tech_svcs.rb file in your initializers and override the config options you want

    Rails.application.config.erp_tech_svcs.configure do |config|
      config.installation_domain = 'localhost:3000'
      config.login_url = '/erp_app/login'
      config.email_notifications_from = 'notifications@noreply.com'
      config.max_file_size_in_mb = 5
      config.session_expires_in_hours = 12 # this is used by DeleteExpiredSessionsJob to purge inaactive sessions from database
      config.compass_logger_path = "#{Rails.root}/log"
      config.file_assets_location = 'file_assets' # relative to Rails.root
      config.file_protocol = 'http'
      config.file_storage = :filesystem # Can be either :s3 or :filesystem
      config.s3_url_expires_in_seconds = 60
      config.s3_protocol = 'https' # Can be either 'http' or 'https'
    end
    Rails.application.config.erp_tech_svcs.configure!
