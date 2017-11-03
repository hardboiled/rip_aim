class SessionsController < ApplicationController
  include Concerns::Sessionable

  def login
    user = User.find_by_username(params[:username])
    unless user.nil? || user.authenticate(params[:password])
      return render_error_hash(
        'authorization_error', 'username or password does not match our records', :unauthorized
      )
    end
    sign_in(user)
    render 'users/show', status: :ok
  end

  def logout
    sign_out
    head :no_content
  end
end
