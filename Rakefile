task :default => :dev

desc 'Run Jekyll in development mode'
task :dev do
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

task :publish => [:build, :push] do
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