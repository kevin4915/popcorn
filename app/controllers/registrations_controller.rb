class RegistrationsController < Devise::RegistrationsController
  def update
    super do |resource|
      if resource.errors.empty?
        redirect_to root_path and return
      end
    end
  end
end
