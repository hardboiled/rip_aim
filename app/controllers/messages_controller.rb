class MessagesController < ApplicationController
  include Concerns::Paginatable
  before_action :valid_params, only: :index
  before_action :verify_users_exist, only: :index
  before_action :sanitize_pagination_params, only: :index

  def create
    permitted = params.permit(%i[sender_id recipient_id content message_type metadata])
    @message = Message.create(permitted)
    return render_validation_error(@message.errors) if @message.errors.any?
    render :show, status: :created
  end

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
    user_ids = if params[:action] == 'index'
                 params[:users]
               else
                 [params[:sender_id], params[:recipient_id]]
               end
    head(:not_found) unless User.where(id: user_ids).length == 2
  end
end
