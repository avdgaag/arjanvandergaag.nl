require 'time'
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::LinkTo
include Nanoc3::Helpers::XMLSitemap

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

def cache_busted(path)
  real_path = File.join(File.dirname(__FILE__), '..', 'content', path)
  ext = File.extname(path)
  path.sub(ext, '_cb' + File.mtime(real_path).strftime('%Y%m%d%H%m') + ext)
end

def openid(id)
  <<-EOS % id
        <link rel="openid.server" href="http://www.myopenid.com/server">
        <link rel="openid.delegate" href="%1$s">
        <link rel="openid2.local_id" href="%1$s">
        <link rel="openid2.provider" href="http://www.myopenid.com/server">
        <meta http-equiv="X-XRDS-Location" content="http://www.myopenid.com/xrds?username=%1$s">
EOS
end