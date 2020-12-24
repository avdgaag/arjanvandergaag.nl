require 'rss'
require 'polites/nanoc'
use_helper Nanoc::Helpers::LinkTo

def article_parts(content)
  content = Nokogiri::HTML.fragment(content)
  title = content.css('h1').first&.remove
  leader = content.css('p').first&.remove
  [title, leader, content]
end

# Filter for removing all HTML tags from some content.
Nanoc::Filter.define(:drop_empty_paragraphs) do |content, _params|
  doc = Nokogiri::HTML.fragment(content)
  doc.children.each do |node|
    node.remove if node.name == 'p' && node.children.empty?
  end
  doc.to_html
end
