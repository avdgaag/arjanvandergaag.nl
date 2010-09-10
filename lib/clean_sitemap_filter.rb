class CleanSitemapFilter < Nanoc3::Filter
  identifier :clean_sitemap
  def run(content, params = {})
    content.gsub(/<url>\s*<loc>[^<]+?(txt|css|png|jpg|xml|js|404\.html|google[a-z0-9]+\.html|\.htaccess)<\/loc>\s*<lastmod>.+?<\/lastmod>\s*<\/url>\s*/m, '')
  end
end