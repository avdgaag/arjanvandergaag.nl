def create_sitemap
  # Make items that should not appear in the sitemap hidden.
  # This by default works on all image files and typical assets,
  # as well as error pages and htaccess.
  # The is_hidden attribute is only explicitly set if it is absent,
  # allowing per-file overriding.
  @items.each do |item|
    if %w{png gif jpg jpeg css xml js txt}.include?(item[:extension]) ||
       item.identifier =~ /404|500|htaccess/
      item[:is_hidden] = true unless item.attributes.has_key?(:is_hidden)
    end
  end

  # Generate default sitemap
  @items << Nanoc3::Item.new(
    "<%= xml_sitemap %>",
    { :extension => 'xml' },
    '/sitemap/'
  )
end

def create_webmaster_tools_authentications
  @site.config[:webmaster_tools].each do |file|
    next if file[:identifier].nil?
    content    = file.delete(:content)
    identifier = file.delete(:identifier)
    file.merge({ :is_hidden => true })
    @items << Nanoc3::Item.new(
      content,
      file,
      identifier
    )
  end
end

def create_robots_txt
  if @site.config[:robots]
    content = if @site.config[:robots][:default]
      "User-agent: *\nDisallow: /assets\nAllow: /assets/images\nSitemap: /sitemap.xml"
    else
      [
        'User-Agent: *',
        @site.config[:robots][:disallow].map { |l| "Disallow: #{l}" },
        (@site.config[:robots][:allow] || []).map { |l| "Allow: #{l}" },
        "Sitemap: #{@site.config[:robots][:sitemap]}"
      ].flatten.compact.join("\n")
    end
    @items << Nanoc3::Item.new(
      content,
      { :extension => 'txt', :is_hidden => true },
      '/robots/'
    )
  end
end

def create_feed
  @items << Nanoc3::Item.new(
    "<%= atom_feed %>",
    {
      :extension   => 'xml',
      :title       => 'arjanvandergaag.nl atom feed',
      :author_name => 'Arjan van der Gaag',
      :author_uri  => 'http://arjanvandergaag.nl',
      :feed_url    => 'http://arjanvandergaag.nl/feed/'
    },
    '/atom/'
  )
end