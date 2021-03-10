require 'nokogiri'

module Spider
  class Americanas < Spider::SpiderBase
    CSS_QUERY = {
      product: 'div [@class^="col__StyledCol-sc-1snw5v3-0 epVkvq"]',
      name: 'span[@class*="src__Name"]',
      id: 'a'
    }.freeze

    LAMBDA_DICT = {
      name: ->(noko) { noko.at_css(CSS_QUERY[:name]).text },
      id: lambda do |noko|
        result = noko.at_css(CSS_QUERY[:id]).attributes['to'].value.remove('/produto')
        result.split('?').first[1..]
      end
    }.freeze

    def initialize(product)
      @document = document(path: "busca/#{product}")
    end

    def to_a
      @document.css(CSS_QUERY[:product]).map do |noko|
        LAMBDA_DICT.dup.transform_values do |result_proc|
          result_proc.call(noko)
        end
      end
    end

    private

    def host
      'https://www.americanas.com.br/'
    end
  end
end
