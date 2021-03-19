require 'open-uri'

module Spider
  class SpiderBase
    attr_accessor :category

    def initialize(product = nil)
      self.category = product
    end

    def get_document(path: nil)
      Nokogiri::HTML(URI.open(host + path.to_s, default_headers))
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

    def import
      to_a.each do |result_hash|
        product = Product.find_by(result_hash.slice(:title, :ean, :image_path))
        product = if product.nil?
          # Product.create!(title: )
        end
      end
    end
  end
end
