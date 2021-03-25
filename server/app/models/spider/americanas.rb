require 'nokogiri'

module Spider
  class Americanas < Spider::SpiderBase
    # Americanas's page only support 24 items per page, more it has to be on API

    def to_a
      utilit_set = uri_config[:search]
      document = get_document(path: utilit_set[:path] + category)
      document.css(utilit_set[:css_query][:product]).each_with_object([]) do |noko, memo|
        begin
          result = utilit_set[:lambda_dict].dup.transform_values { |result_proc| result_proc.call(noko) }
          result.merge!(category: category)
          memo << result
        rescue StandardError => e
          raise e unless e.to_s == NO_PRICE_EXCEPTION
        end
      end
    end

    # private

    def instance_hash(id)
      utilit_set = uri_config[:show]
      puts utilit_set[:path] + id.to_s
      document = get_document(path: utilit_set[:path] + id.to_s)

      utilit_set[:lambda_dict].transform_values { |key_proc| key_proc.call(document) }
    end

    # Raw datas

    def uri_config
      {
        search: {
          path: 'busca/',
          lambda_dict: {
            integration_id: lambda do |noko|
              noko.at_css(uri_config[:search][:css_query][:integration_id]).attributes['to'].value
                  .remove('/produto').split('?').first[1..-1]
            end,
            title: ->(noko) { noko.at_css(uri_config[:search][:css_query][:title]).text },
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:search][:css_query][:price])&.text)
            end
          },
          css_query: {
            product: 'div [@class^="col__StyledCol-sc-1snw5v3-0 epVkvq"]',
            integration_id: 'a',
            title: 'span[@class*="src__Name"]',
            price: 'span[@class*="src__PromotionalPrice"]'
          }
        },
        show: {
          path: 'produto/',
          lambda_dict: {
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:show][:css_query][:price])&.text)
            end,
            ean: lambda do |noko|
              noko.at_css(uri_config[:show][:css_query][:tags]).children.children.find do |tag|
                tag.children.first.text == 'Código'
              end.children.last.text
            end,
            tags: lambda do |noko|
              list = noko.at_css(uri_config[:show][:css_query][:tags]).children.children
              list.each_with_object({}) do |tag, memo|
                set = tag.children.map(&:text)
                memo[set.first] = set.second
              end
            end
          },
          css_query: {
            price: 'div[class^="src__BestPrice-sc-1jvw02c-5"]',
            tags: 'table[class^="src__SpecsCell"]'
          }
        }
      }
    end

    def host
      'https://www.americanas.com.br/'
    end
  end
end
