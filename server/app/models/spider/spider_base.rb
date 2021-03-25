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
      { 'User-Agent' => 'Chrome/88.0.4324.190' }
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
