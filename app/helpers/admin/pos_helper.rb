module Admin::PosHelper
  def current_page
    return unless @pages

    @current_page ||= @pages[:current_page]
  end

  def next_page
    return unless @pages

    @next_page ||= (@pages[:current_page] < @pages[:total_pages]) && (@pages[:current_page] + 1)
  end

  def previous_page
    return unless @pages

    @previous_page ||= (@pages[:current_page] > 1) && @pages[:current_page] - 1
  end
end
