require 'time'
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::LinkTo

def published_at(item)
  Time.parse(item[:created_at].to_s).strftime '%d-%m-%Y'
end

def tags(item)
  item[:tags].join(', ')
end

def with_articles
  if (articles = sorted_articles) && articles.any?
    yield articles
  end
end

def next_article(item, offset = -1, prefix = 'Next: ')
  articles = sorted_articles
  if (n = articles.index(item)) && article = articles.at(n + offset)
    prefix + link_to(article[:title], article)
  end
end

def previous_article(item)
  next_article(item, 1, 'Previous: ')
end