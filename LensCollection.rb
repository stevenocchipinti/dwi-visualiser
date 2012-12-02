require 'nokogiri'
require 'open-uri'
require 'json'

class LensCollection

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
    doc.xpath('//div[contains(text(), "$")]').each do |price_element|

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

      # Find minimum and maximum aperture
      parts = lens[:aperture].scan(/f([0-9.]+)-([0-9.]+)/i).flatten
      if parts.any?
        lens[:aperture_min] = parts.first
        lens[:aperture_max] = parts.last
      elsif aperture = lens[:aperture][/[0-9.]+/]
        lens[:aperture_min] = lens[:aperture_max] = aperture
      end

      # Find minimum and maximum focal length
      parts = lens[:focal_length].scan(/([0-9.]+)-([0-9.]+)mm/i).flatten
      if parts.any?
        lens[:focal_length_min] = parts.first
        lens[:focal_length_max] = parts.last
      elsif focal_length = lens[:focal_length][/[0-9.]+/]
        lens[:focal_length_min] = lens[:focal_length_max] = focal_length
      end

      # Generate coodinates of points to plot on a chart
      min = [lens[:focal_length_min], lens[:aperture_min] ]
      max = [lens[:focal_length_max], lens[:aperture_max] ]
      lens[:plot] = min == max ? [min] : [min, max]

      lenses << lens

    end

    lenses
  end

end
