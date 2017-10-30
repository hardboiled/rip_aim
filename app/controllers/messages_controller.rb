class MessagesController < ApplicationController
  include Concerns::Paginatable
  before_action :valid_params, :index
  before_action :verify_users_exist, :index
  before_action :sanitize_pagination_params, :index

  def index
    messages = Message.between_users(*params[:users])
    @total = messages.count
    @data = messages.offset(@page * @limit).limit(@limit)
  end

  private

  def valid_params
    if params[:users].blank? || !params[:users].is_a?(Array) || params[:users].length != 2
      render_error_hash(
        'invalid_request_error', 'must provide exactly two users to compare', :bad_request
      )
    end
  end

  def verify_users_exist
    head(:not_found) unless User.where(id: params[:users]).length == 2
  end
end
