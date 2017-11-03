class MessagesController < ApplicationController
  include Concerns::Paginatable
  include Concerns::Sessionable

  before_action :require_authentication
  before_action :require_sender_is_current_user
  before_action :valid_params, :verify_users_exist, :sanitize_pagination_params, only: :index


  def create
    permitted = params.permit(%i[sender_id recipient_id content message_type metadata])
    @message = Message.create(permitted)
    return render_validation_error(@message.errors) if @message.errors.any?
    render :show, status: :created
  end

  def index
    messages = Message.between_users(params[:sender_id], params[:recipient_id])
    @total = messages.count
    @data = messages.offset(@page * @limit).limit(@limit)
  end

  private

  def valid_params
    if params[:sender_id].blank? || params[:recipient_id].blank?
      render_error_hash(
        'invalid_request_error', 'must provide exactly sender_id and recipient_id', :bad_request
      )
    end
  end

  def verify_users_exist
    user_ids = [params[:sender_id], params[:recipient_id]]
    head(:not_found) unless User.where(id: user_ids).length == 2
  end

  def require_sender_is_current_user
    return if session[:current_user_id] == params[:sender_id]
    render_error_hash(
      'authorization_error', 'you do not have access to this resource', :unauthorized
    )
  end
end
