# frozen_string_literal: true

require 'pstore'
require_relative '../lib/goodreads'

usage 'goodreads [options]'
aliases :gr
summary 'refresh the list of books from Goodreads'
description 'Use the Goodreads API to download a list of books read and refresh the local HTTP cache in ./data/goodreads.pstore'

flag :h, :help, 'show this message' do
  puts cmd.help
  exit 0
end

option :c, :cache, 'specify path to cache file to use', argument: :optional
option :d, :data, 'specify path to data file to use', argument: :optional
option :a, :auth, 'file with credentials', argument: :optional

run do |opts, _args, _cmd|
  cache_path = opts.fetch(:cache, 'data/http_cache.pstore')
  data_path = opts.fetch(:data, 'data/goodreads.pstore')
  creds = opts.fetch(:auth, 'goodreads.yml')
  id, key, secret = YAML.load_file(creds).values_at(:id, :key, :secret)

  list =
    Goodreads::ParsingDecorator.new(
      Goodreads::HttpCachingDecorator.new(
        PStore.new(cache_path),
        Goodreads::Client.new(id, key, secret),
        refresh: false
      )
    ).list
  content = PStore.new(data_path)
  content.transaction do
    content[:reviews] = list
  end
end
