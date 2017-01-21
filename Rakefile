#!/usr/bin/env ruby

require 'bundler/setup'
require 'rake/clean'
require 'yaml'

CONFIG_FILE = 'config.yml'
if File.exist?(CONFIG_FILE)
  CONFIG = YAML.load_file(CONFIG_FILE).freeze
else
  warn "Configuration file #{CONFIG_FILE} does not exist."
  exit 1
end

OUTPUT_DIR = CONFIG.fetch(:outputs)
INPUT_DIR = CONFIG.fetch(:inputs)
INPUT_FILES = FileList["#{INPUT_DIR}/**/*.*"]
OUTPUT_FILES = INPUT_FILES.pathmap("%{^#{INPUT_DIR},#{OUTPUT_DIR}}X%{.*,*}x") do |ext|
  CONFIG.fetch(:extensions).fetch(ext, ext)
end
CLOBBER.include(OUTPUT_DIR)
OUTPUT_FILES.pathmap('%d').each do |d|
  directory d
end

class Page
  def self.from_file(path)
    content = File.read(path)
    _, front_matter, content = content.split(/---/, 3)
    attributes = YAML.load(front_matter)
    new(content, attributes.merge('path' => path))
  end

  attr_reader :content, :attributes

  def initialize(content, attributes = {})
    @content = content
    @attributes = attributes
  end

  def title
    attributes.fetch('title')
  end

  def created_at
    Time.parse(attributes.fetch('created_at'))
  end

  def updated_at
    File.mtime(attributes.fetch('path'))
  end

  def url
    attributes.fetch('path').pathmap("%{#{INPUT_DIR},}X.html")
  end

  def write(path)
    File.open(path, 'wb') do |f|
      f.write transform
    end
  end

  private

  def transform
    Typogruby.improve Kramdown::Document.new(content, options).to_html
  end

  def options
    CONFIG.fetch(:kramdown).merge(front_matter: attributes)
  end
end

def map(pathmap, *dependencies)
  [
    ->(f) { f.pathmap('%d') },
    CONFIG_FILE,
    *dependencies,
    ->(f) { f.pathmap("%{^#{OUTPUT_DIR},#{INPUT_DIR}}p").pathmap(pathmap) }
  ]
end

rule '.html' => map('%X.erb') do |t|
  warn "compile #{t.name}"
  require 'typogruby'
  require 'erb'
  require 'kramdown'
  require 'time'
  require 'rouge'
  @pages = INPUT_FILES.grep(/\.md$/).map { |p| Page.from_file(p) }
  content = File.read(t.prerequisites.last)
  template = ERB.new(content).result(binding)
  Page.new(template).write(t.name)
end

rule '.html' => map('%X.md', CONFIG.dig(:kramdown, :template)) do |t|
  warn "compile #{t.name}"
  require 'kramdown'
  require 'time'
  require 'rouge'
  require 'typogruby'
  Page.from_file(t.prerequisites.last).write(t.name)
end

rule '.xml' => map('%X.rb') do |t|
  warn "compile #{t.name}"
  @pages = INPUT_FILES.grep(/\.md$/).map { |p| Page.from_file(p) }
  require 'rss'
  rss = instance_eval(File.read(t.prerequisites.last), t.prerequisites.last, 1)
  File.open(t.name, 'wb') do |f|
    f.write rss.to_s + "\n"
  end
end

rule '.css' => map('%X.scss') do |t|
  warn "compile #{t.name}"
  require 'sass'
  css = Sass::Engine.new(
    File.read(t.prerequisites.last),
    CONFIG.fetch(:sass)
  ).render
  File.open(t.name, 'wb') do |f|
    f.write css
  end
end

rule /#{OUTPUT_DIR}.*\.(?:#{Regexp.union(CONFIG.fetch(:static_files))})/ => map('%p') do |t|
  cp t.prerequisites.last, t.name
end

desc "Compile the entire site into ./#{OUTPUT_DIR}"
task compile: OUTPUT_FILES

desc 'Force re-compilation of the entire site'
task recompile: %i(clobber compile)

desc 'Start a local development server to preview the site'
task :serve do
  require 'webrick'
  server = WEBrick::HTTPServer.new(
    Port: CONFIG.dig(:serve, :port),
    DocumentRoot: File.join(__dir__, OUTPUT_DIR)
  )
  trap 'INT' do
    server.shutdown
  end
  server.start
end

task default: :compile
