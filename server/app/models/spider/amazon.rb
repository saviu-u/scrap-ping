module Spider
  class Amazon < Spider::SpiderBase
    def uri_config
      {
        category: {
          path: 'gp/most-wished-for/',
          lambda_dict: {
            integration_id: lambda do |noko|
              id_polish(noko.at_css(uri_config[:category][:css_query][:integration_id]).attributes['href'].value)
            end,
            title: ->(noko) { noko.at_css(uri_config[:category][:css_query][:title]).text.strip },
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:category][:css_query][:price])&.text)
            end
          },
          css_query: {
            product: 'li[role="gridcell"]',
            integration_id: 'a[class^="a-link-normal"]',
            title: 'div[class^="p13n-sc-trunc"]',
            price: 'span[class^="p13n-sc-price"]'
          }
        },
        search: {
          path: 's?k=',
          lambda_dict: {
            integration_id: lambda do |noko|
              id_polish(noko.at_css(uri_config[:search][:css_query][:integration_id]).attributes['href'].value)
            end,
            title: ->(noko) { noko.at_css(uri_config[:search][:css_query][:title]).text },
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:search][:css_query][:price])&.text)
            end
          },
          css_query: {
            product: 'div[data-component-type^="s-search-result"]',
            integration_id: 'a[class="a-link-normal a-text-normal"]',
            title: 'span[class="a-size-base-plus a-color-base a-text-normal"]',
            price: 'span[class="a-price-whole"]'
          }
        },
        show: {
          path: 'dp/',
          lambda_dict: {
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:show][:css_query][:price])&.text)
            end,
            ean: lambda do |noko|
              noko.at_css(uri_config[:show][:css_query][:tags]).css('tr').find do |tag|
                tag.children.children.first.text.strip == 'EAN'
              end.children.children.last.text.strip
            end,
            tags: lambda do |noko|
              list = noko.at_css(uri_config[:show][:css_query][:tags]).css('tr')
              list.each_with_object({}) do |tag, memo|
                set = tag.children.children.map(&:text).map(&:strip)
                memo[set.first] = set.second
              end
            end
          },
          css_query: {
            price: 'span[class^="a-size-base a-color-price"]',
            tags: 'table[id^="productDetails_techSpec_section"]'
          }
        }
      }
    end

    def category_hash
      {
        'tv' => 'electronics/16243822011'
      }
    end

    def host
      'https://www.amazon.com.br/'
    end

    private

    def id_polish(id)
      id.split('dp').second[1..10]
    end
  end
end
