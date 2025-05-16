module Pagination
  extend ActiveSupport::Concern

  DEFAULT_PER_PAGE = 25

  private def page_no
    page_no = params[:page_no]&.to_i
    page_no&.positive? ? page_no : 1
  end

  private def per_page
    return @per_page if @per_page

    per_page = params[:per_page]&.to_i
    @per_page ||= per_page&.positive? ? per_page : DEFAULT_PER_PAGE
  end

  def paginate
    ->(it) do
      count = it.count
      total_pages = (count.to_f / per_page).ceil
      current_page = [ page_no, total_pages ].min

      @pages = {
        current_page: current_page,
        total_pages: total_pages
      }

      it.limit(per_page).offset((current_page-1) * per_page)
    end
  end
end
