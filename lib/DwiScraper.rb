require 'nokogiri'
require 'open-uri'
require 'json'
require './lib/Lens'

class DwiScraper

  attr_accessor :lenses
  DWI_URL = 'http://www.dwidigitalcameras.com.au'


  def initialize(url)
    @lenses = get_lenses(url)
  end


  def to_json(*opts)
    @lenses.to_json(*opts)
  end


  def get_lenses(url)

    # Find the element with the pricetag
    # Asend up the DOM until the containing table element is found
    # Descend down the DOM until the link with the 'highlight' class is found
    #   This element contains the description (with focal length and aperture)

    doc = Nokogiri::HTML(open(url))

    lenses = []
    @stats = { parsed: 0, failed: 0 }
    doc.xpath('//div[contains(text(), "$")]').each do |price_element|

      begin
        containing_element = price_element.xpath("ancestor::table[1]")
        name_element = containing_element.css('.highlight')
        image_element = containing_element.xpath("ancestor::table[1]//img")

        lenses << Lens.new(
          name:  name_element.text,
          link:  DWI_URL + name_element.first.attribute('href').text,
          image: DWI_URL + image_element.first.attribute('src').text,
          price: price_element.text
        )
        @stats[:parsed] += 1
      rescue
        @stats[:failed] += 1
        next
      end

    end

    print_report
    lenses
  end


  def print_report
    $stderr.puts "Report:"
    $stderr.puts "  Parsed lenses: #{@stats[:parsed]}"
    $stderr.puts "  Failed lenses: #{@stats[:failed]}"
  end

end
