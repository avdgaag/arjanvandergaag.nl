require 'bundler'
Bundler.require
include Nanoc::Helpers::Blogging
include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Tagging

def articles_by_year
  hash = Hash.new { |h, k| h[k] = [] }
  sorted_articles.inject(hash) do |output, article|
    year = attribute_to_time(article[:created_at]).year
    output[year] << article
    output
  end
end
