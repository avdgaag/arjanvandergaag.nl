require 'xmlrpc/client'
require 'net/http'
require 'uri'
require 'yaml'
require 'nanoc3/tasks'

desc 'Push changes to live server and ping services'
task :publish => ['deploy:rsync', :ping]

desc 'Notify verious services of the updated website'
task :ping => ['ping:sitemap', 'ping:pingomatic']

def config
  @config ||= YAML.load_file(File.join(File.dirname(__FILE__), 'config.yaml'))
end

namespace :ping do
  task :sitemap do
    puts 'Telling Google Webmaster tools about our updated sitemap.xml'
    Net::HTTP.get(
        'www.google.com',
        '/webmasters/tools/ping?sitemap=' +
        URI.escape(File.join(config['base_url'], 'sitemap.xml'))
    )
  end

  task :pingomatic do
    puts 'Telling ping-o-matic about our updated site'
    XMLRPC::Client.new('rpc.pingomatic.com', '/').call(
      'weblogUpdates.extendedPing',
      'Arjan van der Gaag',
      'http://arjanvandergaag.nl',
      'http://arjanvandergaag.nl/atom.xml'
    )
  end
end
