domain = 'http://arjanvandergaag.nl'
RSS::Maker.make('atom') do |xml|
  xml.channel.author = 'Arjan van der Gaag'
  xml.channel.updated = Time.now.to_s
  xml.channel.about = domain + '/feed.xml'
  xml.channel.title = 'arjanvandergaag.nl'

  @pages.each do |page|
    xml.items.new_item do |item|
      item.link = domain + page.url
      item.title = page.title
      item.updated = page.updated_at
    end
  end
end
