class CaptchaController < ActionController::Base

  include Knitkit::Extensions::Railties::ActionController::CaptchaHelper

  before_filter :setup_visual_captcha

  def setup_visual_captcha
  	@session = VisualCaptcha::Session.new session
  	@headers = {
        'Access-Control-Allow-Origin' => '*'
    }
  end

  def start
  	captcha = VisualCaptcha::Captcha.new @session

    captcha.generate params[:how_many]

    render json: captcha.frontend_data
  end

  def audio
  	captcha = VisualCaptcha::Captcha.new @session

    type = params[:type]
    type = 'mp3' if type != 'ogg'

    if (body = captcha.stream_audio @headers, type)
      send_data body, type: type, disposition: 'inline'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def image
  	captcha = VisualCaptcha::Captcha.new @session

    if (body = captcha.stream_image @headers, params[:index], params[:retina])
      send_data body, type: 'image/png', disposition: 'inline'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def validate
    if captcha_valid?
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

end
