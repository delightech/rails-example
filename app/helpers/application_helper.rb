module ApplicationHelper
  include HtmlBuilder

  def document_title
    if @title.present?
      "#{@title} - GAE Rails"
    else
      "GAE Rails"
    end
  end
end
