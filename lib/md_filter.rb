module Haml::Filters::Md
  include Haml::Filters::Base

  def render(text)
    Typogruby.improve Kramdown::Document.new(text, auto_ids: false).to_html
  end
end

