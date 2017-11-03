module Concerns
  module Sessionable
    extend ActiveSupport::Concern
    include Concerns::Errorable

    def sign_in(user)
      session[:current_user_id] = user.id
      self.current_user = user
    end

    def signed_in?
      current_user.present?
    end

    def current_user=(user)
      @current_user = user
    end

    def current_user
      @current_user ||= User.find_by(id: session[:current_user_id])
    end

    def sign_out
      self.current_user = nil
      session.delete(:current_user_id)
    end

    def require_authentication
      return if signed_in?
      render_error_hash(
        'authorization_error', 'must be logged in to access this resource', :unauthorized
      )
    end
  end
end
