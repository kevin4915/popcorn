class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action do
    I18n.locale = :fr
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protected

  # Autoriser le champ personnalisé pour sign_up et account_update
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[last_name first_name Netflix DisneyPlus AmazonPrime CanalPlus HBO
                                               avatar])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[last_name first_name Netflix DisneyPlus AmazonPrime CanalPlus HBO
                                               avatar])
  end
end
