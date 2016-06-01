module Knitkit
  module Extensions
    module Railties
      module ActionController
        module CaptchaHelper

          def captcha_valid?
            is_valid = nil

            captcha_session = VisualCaptcha::Session.new session

            captcha = VisualCaptcha::Captcha.new captcha_session
            frontend_data = captcha.frontend_data()

            if frontend_data.nil?
              is_valid = false
            else
              # If an image field name was submitted, try to validate it
              if ( image_answer = params[ frontend_data[ 'imageFieldName' ] ] )
                if captcha.validate_image image_answer
                  is_valid = true
                else
                  is_valid = false
                end
              elsif ( audio_answer = params[ frontend_data[ 'audioFieldName' ] ] )
                if captcha.validate_audio audio_answer.downcase
                  is_valid = true
                else
                  is_valid = false
                end
              else
                is_valid = false
              end
            end

            is_valid
          end

        end # CaptchaHelper
      end # ActionController
    end # Railties
  end # Extensions
end # Knitkit
