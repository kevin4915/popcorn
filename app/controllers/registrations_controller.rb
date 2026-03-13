class RegistrationsController < Devise::RegistrationsController
  private

  def account_update_params
    params.require(:user).permit(
      :first_name, :last_name, :email,
      :password, :password_confirmation, :current_password,
      :avatar,
      :Netflix, :DisneyPlus, :AmazonPrime, :CanalPlus, :HBO
    )
  end
end
