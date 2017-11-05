class UsersController < ApplicationController
  include Concerns::Sessionable
  include Concerns::Paginatable

  before_action :require_authentication, only: %i[show update index]
  before_action :session_for_user, only: %i[show update]
  before_action :sanitize_pagination_params, only: :index

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

  def index
    if params[:search_prefix].blank?
      return render_error_hash('invalid_request_error', 'must provide search_prefix', :bad_request)
    end
    users = User.username_starts_with(params[:search_prefix])
    @total = users.count
    @data = users.offset(@page * @limit).limit(@limit)
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
