require 'open-uri'

module Spider
  class SpiderBase
    attr_accessor :category

    NO_PRICE_EXCEPTION = 'NO_PRICE_EXCEPTION'

    def initialize(product = nil)
      self.category = product
    end

    def get_document(path: nil)
      Nokogiri::HTML(URI.open(host + path.to_s, default_headers))
    end

    def import
      to_a.each do |result|
        FetchProductJob.perform_later(result, self.class)
      end
    end

    def model
      Shop.find_by(spider_name: self.class.to_s)
    end

    private

    def default_headers
      {
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36',
        'accept' => 'text/html',
        'sec-ch-ua' => '"Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99"',
        'upgrade-insecure-requests' => '1'
      }
    end

    def host
      raise 'Define a host method to your host'
    end

    def to_a
      raise 'Define the method \'to_a\' first'
    end

    # Tools

    def money_to_float(money)
      money&.remove('R$')&.tr('.,', ' .')&.delete(' ')&.to_f || raise(NO_PRICE_EXCEPTION)
    end
  end
end
