require 'nokogiri'
require 'open-uri'
require 'json'
require './Scraper'

class DwiScraper
  include Scraper

  attr_accessor :lenses

  DWI_URL = 'http://www.dwidigitalcameras.com.au'

  def initialize(url)
    @lenses = get_lenses(url)
  end

  def to_json
    @lenses.to_json
  end


  def get_lenses(url)

    # Find the element with the pricetag
    # Asend up the DOM until the containing table element is found
    # Descend down the DOM until the link with the 'highlight' class is found
    #   This element contains the description (with focal length and aperture)

    doc = Nokogiri::HTML(open(url))

    lenses = []
    stats = {:parsed => 0, :failed => 0}
    doc.xpath('//div[contains(text(), "$")]').each do |price_element|

      begin

        containing_element = price_element.xpath("ancestor::table[1]")
        name_element = containing_element.css('.highlight')
        image_element = containing_element.xpath("ancestor::table[1]//img")

        lens = {
          name:          name_element.text,
          link:          DWI_URL + name_element.first.attribute('href').text,
          image:         DWI_URL + image_element.first.attribute('src').text,
          aperture:      name_element.text[/\bf\/?[0-9.-]+/i],
          focal_length:  name_element.text[/[0-9.-]+mm/i],
          price:         price_element.text[/\$[0-9.]+/]
        }

        # Only care about proper lenses (not teleconverters, etc.)
        next if !lens[:aperture] || !lens[:focal_length]

        split_aperture!(lens)
        split_focal_length!(lens)
        generate_plot!(lens)

        lenses << lens
        stats[:parsed] += 1

      rescue
        stats[:failed] += 1
        next
      end

    end

    $stderr.puts "Could not parse #{stats[:failed]} lenses!" if stats[:failed] > 0
    lenses
  end

end