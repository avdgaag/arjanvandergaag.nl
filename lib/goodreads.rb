require 'net/https'
require 'rexml/document'
require 'time'

module Goodreads
  class Entity
    def self.attribute(name, type: String, at: name, default: nil, null: false)
      @attributes ||= {}
      @attributes[name] = { type: type, at: at, default: default, null: null }
      attr_accessor name
    end

    def self.from_xml(element)
      attrs = {}
      @attributes.each do |name, options|
        if options[:default]
          attrs[name] = options[:default]
        end

        if options[:type] == String
          attrs[name] = element.elements[options[:at].to_s].text
        elsif options[:type] == Integer
          attrs[name] = element.elements[options[:at].to_s].text.to_i
        elsif options[:type] == Float
          attrs[name] = element.elements[options[:at].to_s].text.to_f
        elsif options[:type] == :bool
          attrs[name] = element.elements[options[:at].to_s].text == "true"
        elsif options[:type] == DateTime
          text = element.elements[options[:at].to_s].text
          attrs[name] = Time.parse(element.elements[options[:at].to_s].text.strip).to_datetime if text && !text.strip.empty?
        elsif options[:type] == URI
          text = element.elements[options[:at].to_s].text
          attrs[name] = URI.parse(text.strip) if text && !text.strip.empty?
        elsif options[:type].is_a?(Array) && options[:type].size == 1
          attrs[name] = element.elements.to_a(options[:at].to_s).map { |e| options[:type].first.from_xml(e) }
        else
          attrs[name] = options[:type].from_xml(element.elements[options[:at].to_s])
        end
      end
      new(attrs)
    end

    def initialize(attrs = {})
      attrs.each do |key, value|
        public_send(:"#{key}=", value)
      end
      freeze
    end
  end

  class Shelf < Entity
    attribute :id, type: Integer
    attribute :exclusive, type: :bool
    attribute :name
    attribute :review_shelf_id, type: Integer
    attribute :sortable, type: :bool

    def self.from_xml(el)
      new(el.attributes)
    end
  end

  class Author < Entity
    attribute :id, type: Integer
    attribute :name
    attribute :role
    attribute :image_url, type: URI
    attribute :small_image_url, type: URI
    attribute :link, type: URI
    attribute :average_rating, type: Float
    attribute :ratings_count, type: Integer
    attribute :text_reviews_count, type: Integer
  end

  class Book < Entity
    attribute :id, type: Integer
    attribute :isbn
    attribute :isbn13
    attribute :text_reviews_count, type: Integer
    attribute :uri, type: URI
    attribute :title
    attribute :title_without_series
    attribute :image_url, type: URI
    attribute :small_image_url, type: URI, null: true
    attribute :large_image_url, type: URI, null: true
    attribute :link, type: URI
    attribute :num_pages, type: Integer
    attribute :format
    attribute :edition_information
    attribute :publisher
    attribute :publication_day, type: Integer
    attribute :publication_year, type: Integer
    attribute :publication_month, type: Integer
    attribute :average_rating, type: Float
    attribute :ratings_count, type: Integer
    attribute :description
    attribute :published, type: Integer
    attribute :authors, default: [], at: "authors/author", type: [Author]
  end

  class Review < Entity
    attribute :id, type: Integer
    attribute :rating, type: Float
    attribute :votes, type: Integer
    attribute :spoiler_flag, type: :bool
    attribute :spoilers_state
    attribute :recommended_for
    attribute :recommended_by
    attribute :started_at, type: DateTime, null: true
    attribute :read_at, type: DateTime
    attribute :date_added, type: DateTime
    attribute :date_updated, type: DateTime
    attribute :read_count, type: Integer
    attribute :body
    attribute :comments_count, type: Integer
    attribute :url, type: URI
    attribute :link, type: URI
    attribute :owned, type: Integer
    attribute :book, type: Book
    attribute :shelves, default: [], type: [Shelf], at: 'shelves/shelf'
  end

  class ListResponse
    def initialize(body)
      @document = REXML::Document.new(body)
    end

    def has_next_page?
      list_end < list_total
    end

    def next_page
      list_end + 1
    end

    def reviews
      REXML::XPath.match(@document, "//GoodreadsResponse/reviews/review").map do |review_element|
        Review.from_xml(review_element)
      end
    end

    private

    def list_start
      reviews_element.attributes["start"].to_i
    end

    def list_end
      reviews_element.attributes["end"].to_i
    end

    def list_total
      reviews_element.attributes["total"].to_i
    end

    def reviews_element
      REXML::XPath.first(@document, '//reviews')
    end
  end

  class Client
    def initialize(id, key, secret)
      @id = id
      @key = key
      @secret = secret
    end

    def list(shelf: 'read', start: 1, per_page: 50)
      page = (start - 1) / per_page + 1
      uri = URI.parse("https://www.goodreads.com/review/list/#{@id}.xml?key=#{@key}&v=2&shelf=#{shelf}&page=#{page}&per_page=#{per_page}&sort=date_read&order=d")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      should_make_request = true
      if block_given?
        should_make_request = yield request
      end
      if should_make_request
        puts "fetching #{uri.inspect}"
        data = http.request(request)
      else
        puts "skipping #{uri.inspect}"
      end
    end
  end

  class ParsingDecorator
    def initialize(client)
      @client = client
    end

    def list(*args)
      data = @client.list(*args)
      list_response = ListResponse.new(data.body)
      if list_response.has_next_page?
        list_response.reviews + list(start: list_response.next_page)
      else
        list_response.reviews
      end
    end
  end

  class HttpCachingDecorator
    def initialize(cache, client, refresh: true)
      @cache = cache
      @client = client
      @refresh = refresh
    end

    def list(*args)
      cached_response = nil
      uri = nil
      has_cache = nil
      response = @client.list(*args) do |request|
        @cache.transaction do
          uri = request.path
          if cached_response = @cache[uri]
            puts "found a cached response with etag #{cached_response["etag"]}"
            request["If-None-Match"] = cached_response["etag"]
            has_cache = true
          else
            puts "no info in cache"
            has_cache = false
          end
          !has_cache || @refresh
        end
      end
      if !has_cache || @refresh
        case response
        when Net::HTTPNotModified
          puts "returning from cache"
          cached_response
        else
          puts "writing new response to cache"
          @cache.transaction do
            @cache[uri] = response
          end
        end
      else
        cached_response
      end
    end
  end

  class DataSource < Nanoc::DataSource
    identifier :goodreads

    def items
      pstore = PStore.new(@config[:pstore])
      pstore.transaction do
        pstore[:reviews].map do |review|
          identifier = Nanoc::Identifier.new("/#{review.id}")
          new_item(review.book.description || '', { review: review }, identifier)
        end
      end
    end
  end
end
