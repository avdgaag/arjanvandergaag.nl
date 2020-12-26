require 'rss'
require 'polites/nanoc'
use_helper Nanoc::Helpers::LinkTo

# Filter for removing all HTML tags from some content.
Nanoc::Filter.define(:drop_empty_paragraphs) do |content, _params|
  doc = Nokogiri::HTML.fragment(content)
  doc.children.each do |node|
    node.remove if node.name == 'p' && node.children.empty?
  end
  doc.children.first(3).each(&:remove)
  doc.css('p').first.append_class('leader')
  doc.to_html
end
