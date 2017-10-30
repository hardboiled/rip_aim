module Concerns
  module Paginatable
    extend ActiveSupport::Concern

    def default_pagination_limit
      100
    end

    def sanitize_pagination_params(max_limit = default_pagination_limit)
      @page = params[:page].to_i || 0
      @limit = params[:limit].blank? ? max_limit : [max_limit, params[:limit].to_i].min

      if @page < 0 || @limit < 0
        return render_error_hash(
          'invalid_request_error', 'offset and limit cannot be negative', :bad_request
        )
      end
    end
  end
end
