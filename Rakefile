require 'net/http'
require 'uri'
require 'xmlrpc/client'

task :default => :dev

desc 'Ping pingomatic'
task :ping do
  puts '* Pinging ping-o-matic'
  XMLRPC::Client.new('rpc.pingomatic.com', '/').call('weblogUpdates.extendedPing', 'Arjan van der Gaag' , 'http://arjanvandergaag.nl', 'http://arjanvandergaag.nl/atom.xml')
end

desc 'Notify Google of the new sitemap'
task :sitemap do
  puts '* Pinging Google about our sitemap'
  Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + URI.escape('http://arjanvandergaag.nl/sitemap.xml'))
end

desc 'Run Jekyll in development mode'
task :dev do
  puts '* Running Jekyll with auto-generation and server'
  puts `jekyll --auto --server`
end

desc 'Run Jekyll to generate the site'
task :build do
  puts '* Generating static site with Jekyll'
  puts `jekyll`
end

desc 'rsync the contents of ./_site to the server'
task :sync do
  puts '* Publishing files to live server'
  puts `rsync -avz "_site/" avdgaag@avdgaag.webfactional.com:~/webapps/jekyllblog/`
end

desc 'Push source code to Github'
task :push do
  puts '* Pushing to Github'
  puts `git push github master`
end

desc 'Generate and publish the entire site, and send out pings'
task :publish => [:build, :push, :sync, :sitemap, :ping] do
end

desc 'Create post with TITLE in CAT'
task :post do
  unless title = ENV['TITLE']
    puts "USAGE: rake post TITLE='the post title'"
    exit(1)
  end
  category = ENV['CAT'] || ''
  post_title = "#{Date.today}-#{title.downcase.gsub(/[^\w]+/, '-')}"

  post_path = File.join(File.dirname(__FILE__), category, '_posts')
  FileUtils.mkpath(post_path)

  post_file = File.join(post_path, "#{post_title}.markdown")

  File.open(post_file, "w") do |f|
    f << <<-EOS.gsub(/^    /, '')
    ---
    layout: post
    title: #{title}
    ---

    EOS
  end

  puts `git add #{post_file}`

  if (ENV['EDITOR'])
    system ("#{ENV['EDITOR']} #{post_file}")
  end
end