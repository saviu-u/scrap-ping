require 'nokogiri'

module Spider
  class Americanas < Spider::SpiderBase
    CSS_QUERY = {
      product: 'div [@class^="col__StyledCol-sc-1snw5v3-0 epVkvq"]',
      id: 'a',
      name: 'span[@class*="src__Name"]',
      price: 'span[@class*="src__PromotionalPrice"]'
    }.freeze

    LAMBDA_DICT = {
      id: lambda do |noko|
        result = noko.at_css(CSS_QUERY[:id]).attributes['to'].value.remove('/produto')
        result.split('?').first[1..-1]
      end,
      name: ->(noko) { noko.at_css(CSS_QUERY[:name]).text },
      price: lambda do |noko|
        noko.at_css(CSS_QUERY[:price]).text.remove('R$').tr('.,', ' .').delete(' ').to_f
      end
    }.freeze

    def initialize(product)
      super()
      self.category = product
    end

    # Americanas's page only support 24 items per page, more it has to be on API
    def to_a
      get_document(path: "busca/#{category}").css(CSS_QUERY[:product]).map do |noko|
        LAMBDA_DICT.dup.transform_values { |result_proc| result_proc.call(noko) }
      end
    end

    private

    def host
      'https://www.americanas.com.br/'
    end
  end

end
