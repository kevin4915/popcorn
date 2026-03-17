class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action do
    I18n.locale = :fr
  end

  allow_browser versions: :modern
  stale_when_importmap_changes

  def after_sign_in_path_for(resource)
    welcome_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[last_name first_name username Netflix DisneyPlus AmazonPrime CanalPlus
                                               HBO avatar])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[last_name first_name username Netflix DisneyPlus AmazonPrime CanalPlus
                                               HBO avatar])
  end
end
