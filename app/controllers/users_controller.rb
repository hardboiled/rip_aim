class UsersController < ApplicationController
  before_action :fetch_user, only: %i[show update]

  def show; end

  def create
    @user = User.create(permitted_params)
    return render_validation_error(@user.errors) if @user.errors.any?
    render :show, status: :created
  end

  def update
    @user.update(permitted_params)
    return render_validation_error(@user.errors) if @user.errors.any?
    render :show
  end

  private

  def fetch_user
    @user = User.find_by_id(params[:id])
    return head :not_found if @user.nil?
  end

  def permitted_params
    params.permit(%i[username password])
  end
end
