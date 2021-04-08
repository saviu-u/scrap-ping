module Spider
  class Amazon < Spider::SpiderBase
    def uri_config
      {
        category: {
          path: 'gp/most-wished-for/',
          lambda_dict: {
            id_integration: lambda do |noko|
              id_polish(noko.at_css(uri_config[:category][:css_query][:id_integration]).attributes['href'].value)
            end,
            title: ->(noko) { noko.at_css(uri_config[:category][:css_query][:title]).text.strip },
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:category][:css_query][:price])&.text)
            end
          },
          css_query: {
            product: 'li[role="gridcell"]',
            id_integration: 'a[class^="a-link-normal"]',
            title: 'div[class^="p13n-sc-trunc"]',
            price: 'span[class^="p13n-sc-price"]'
          }
        },
        search: {
          path: 's?k=',
          lambda_dict: {
            id_integration: lambda do |noko|
              id_polish(noko.at_css(uri_config[:search][:css_query][:id_integration]).attributes['href'].value)
            end,
            title: ->(noko) { noko.at_css(uri_config[:search][:css_query][:title]).text },
            price: lambda do |noko|
              money_to_float(noko.at_css(uri_config[:search][:css_query][:price])&.text)
            end
          },
          css_query: {
            product: 'div[data-component-type^="s-search-result"]',
            id_integration: 'a[class="a-link-normal a-text-normal"]',
            title: 'span[class="a-size-base-plus a-color-base a-text-normal"]',
            price: 'span[class="a-price-whole"]'
          }
        },
        show: {
          path: 'dp/',
          lambda_dict: {
            price: lambda do |noko|
              price = noko.at_css(uri_config[:show][:css_query][:price])&.text&.strip
              price = noko.at_css(uri_config[:show][:css_query][:price_medium])&.text if price.blank?
              money_to_float(price)
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
            price_medium: 'span[class^="a-size-medium a-color-price"]',
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

    def default_headers
      {
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36',
        'accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'upgrade-insecure-requests' => '1'
      }
    end
  end
end
