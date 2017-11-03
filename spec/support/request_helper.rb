require 'active_support/concern'

module RequestHelper
  extend ActiveSupport::Concern

  included do
    %I[get patch post put delete].each do |x|
      define_method("auth_#{x}") do |controller_action, params, session_id|
        session[:current_user_id] = session_id
        send(
          x.to_sym,
          controller_action,
          params.merge(format: :json)
        )
      end
    end
  end
end
