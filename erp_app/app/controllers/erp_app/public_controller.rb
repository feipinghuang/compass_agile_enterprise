module ErpApp
  class PublicController < ActionController::Base
    protect_from_forgery only: []

    before_filter :set_file_support

    # TODO:
    # reorder menuitems
    # drag and drop image into ckeditor uses bad (but somehow not broken, i.e. ../../images/) url (filesystem on firefox, chrome OK)

    # Download Inline Example: /download/filename.ext?path=/directory&disposition=inline
    # Download Prompt Example: /download/filename.ext?path=/directory&disposition=attachment
    def download
      filename = "#{params[:filename]}.#{params[:format]}"

      # remove trailing period if present
      if filename.last == '.'
        filename.chop!
      end

      path = params[:path].blank? ? nil : params[:path].gsub("/#{params[:filename]}.#{params[:format]}", '')
      disposition = params[:disposition]

      file = FileAsset.where(:name => filename)
      file = file.where(:directory => path) if path
      file = file.first

      unless file.nil?
        if file.is_secured?
          begin
            unless current_user == false
              current_user.with_capability(:download, file) do
                serve_file(file, disposition)
              end
            else
              raise ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability => ex
            render :text => ex.message and return
          rescue => ex
            Rails.logger.error ex.message
            Rails.logger.error ex.backtrace.join("\n")

            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier

            render :text => ex.message and return
          end
        else
          serve_file(file, disposition)
        end
      else
        render :text => 'File not found.'
      end
    end

    protected

    def serve_file(file, disposition=nil)
      #type = (file.type == 'Image' ? "image/#{params[:format]}" : file.data_content_type)
      type = file.data_content_type

      if ErpTechSvcs::Config.file_storage == :s3
        path = File.join(file.directory,file.name).sub(%r{^/},'')
        options = { :response_content_disposition => disposition }
        options[:expires] = ErpTechSvcs::Config.s3_url_expires_in_seconds if file.is_secured?
        redirect_to @file_support.bucket.objects[path].url_for(:read, options).to_s
      else
        # to use X-Sendfile or X-Accel-Redirect, set config.action_dispatch.x_sendfile_header in environment config file
        if disposition
          send_file File.join(Rails.root,file.directory,file.name), :type => type, :disposition => disposition
        else
          send_file File.join(Rails.root,file.directory,file.name), :type => type
        end
      end
    end

    def set_file_support
      @file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    end

  end
end
