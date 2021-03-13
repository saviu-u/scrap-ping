require 'open-uri'

module Spider
  class SpiderBase
    attr_accessor :category

    def get_document(path: nil)
      @get_document ||= Nokogiri::HTML(URI.open(host + path.to_s, default_headers))
    end

    private

    def default_headers
      { 'User-Agent' => 'Chrome/88.0.4324.190' }
    end

    def host
      raise 'Define a host method to your host'
    end
  end
end
