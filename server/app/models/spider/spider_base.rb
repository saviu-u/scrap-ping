require 'open-uri'
require 'nokogiri'

module Spider
  class SpiderBase
    attr_accessor :category, :search, :category_title

    NO_PRICE_EXCEPTION = 'NO_PRICE_EXCEPTION'

    def initialize(product = nil, category_title: nil)
      self.search = product
      self.category = category_hash[product] if category_hash[product]
      self.category_title = category_title
    end

    def get_document(path: nil)
      puts '*' * 100, host + path.to_s
      Nokogiri::HTML(URI.open(host + path.to_s, default_headers))
    end

    def import
      to_a&.compact&.each do |result|
        FetchProductJob.perform_later(result, self.class)
      end
    end

    def model
      Shop.find_by(spider_name: self.class.to_s)
    end

    def to_a
      utilit_set = uri_config[search_type]
      document = get_document(path: search_path)
      document.css(utilit_set[:css_query][:product]).each_with_object([]) do |noko, memo|
        begin
          result = utilit_set[:lambda_dict].dup.transform_values { |result_proc| result_proc.call(noko) }
          result.merge!(category: category_title || search)
          memo << result
        rescue StandardError => e
          raise e unless e.to_s == NO_PRICE_EXCEPTION
        end
      end
    rescue OpenURI::HTTPError
      puts '404'
      nil
    end

    def search_path
      uri_config[search_type].to_h[:path] + search_object
    end

    def instance_hash(id)
      utilit_set = uri_config[:show]
      puts utilit_set[:path] + id.to_s
      document = get_document(path: utilit_set[:path] + id.to_s)

      utilit_set[:lambda_dict].transform_values { |key_proc| key_proc.call(document) }
    end

    private

    def search_type
      category ? :category : :search
    end

    def search_object
      send(search_type)
    end

    # To define

    def default_headers
      {
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36',
        'accept' => 'text/html',
        'sec-ch-ua' => '"Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"',
        'upgrade-insecure-requests' => '1'
      }
    end

    def category_hash
      {}
    end

    def host
      raise 'Define a host method to your host'
    end

    # Tools

    def money_to_float(money)
      money&.remove('R$')&.tr('.,', ' .')&.delete(' ')&.to_f || raise(NO_PRICE_EXCEPTION)
    end
  end
end
