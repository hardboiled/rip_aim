class UsersController < ApplicationController
  include Concerns::Sessionable

  before_action :require_authentication, only: %i[show update]
  before_action :session_for_user, only: %i[show update]

  def show; end

  def create
    user = User.create(permitted_params)
    return render_validation_error(user.errors) if user.errors.any?
    sign_in(user)
    render :show, status: :created
  end

  def update
    current_user.update(permitted_params)
    return render_validation_error(current_user.errors) if current_user.errors.any?
    render :show
  end

  def login
    user = User.find_by_username(params[:username])
    unless user.nil? || user.authenticate(params[:password])
      return render_error_hash(
        'authorization_error', 'username or password does not match our records', :unauthorized
      )
    end
    sign_in(user)
    render :show, status: :ok
  end

  def logout
    sign_out
    render :show, status: :ok
  end

  private

  def session_for_user
    return if current_user.id == params[:id]
    render_error_hash(
      'authorization_error', 'user does not own resource', :unauthorized
    )
  end

  def permitted_params
    params.permit(%i[username password])
  end
end
