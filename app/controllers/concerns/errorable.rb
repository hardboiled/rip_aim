module Concerns
  module Errorable
    extend ActiveSupport::Concern

    def render_validation_error(model_errors)
      render_error_hash(
        'validation_error',
        'One or more expected parameters were invalid',
        :unprocessable_entity,
        validations: model_errors
      )
    end

    def render_error_hash(type, message, status, options = {})
      error = {
        type: type,
        message: message
      }.merge!(options)
      render json: { error: error }, status: status
    end
  end
end
