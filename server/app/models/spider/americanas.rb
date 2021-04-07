module Spider
  class Americanas < Spider::SpiderBase
    def uri_config
      {
        category: {
          path: 'categoria/',
          lambda_dict: {
            id_integration: lambda do |noko|
              id_polish(noko.at_css(uri_config[:category][:css_query][:id_integration]).attributes['href'].value)
            end,
            title: ->(noko) { noko.at_css(uri_config[:category][:css_query][:title]).text },
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:category][:css_query][:price])&.text)
            end
          },
          css_query: {
            product: 'div[class^="product-grid-item ProductGrid__GridColumn"]',
            id_integration: 'a[class^="Link"]',
            title: 'h2[class^="TitleUI"]',
            price: 'span[class^="PriceUI"]'
          }
        },
        search: {
          path: 'busca/',
          lambda_dict: {
            id_integration: lambda do |noko|
              id_polish(noko.at_css(uri_config[:search][:css_query][:id_integration]).attributes['to'].value)
            end,
            title: ->(noko) { noko.at_css(uri_config[:search][:css_query][:title]).text },
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:search][:css_query][:price])&.text)
            end
          },
          css_query: {
            product: 'div [@class^="col__StyledCol-sc-1snw5v3-0 epVkvq"]',
            id_integration: 'a',
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
                tag.children.first.text == 'Código de barras'
              end.children.last.text.match(/\d+/).to_a[0]
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

    def category_hash
      {
        'tv' => 'tv-e-home-theater/tv'
      }
    end

    def host
      'https://www.americanas.com.br/'
    end

    private #Americanas helpers

    def id_polish(id)
      id.remove('/produto').split('?').first[1..-1]
    end
  end
end
