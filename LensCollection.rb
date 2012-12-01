require 'nokogiri'
require 'open-uri'
require 'json'

class LensCollection

  attr_accessor :lenses

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
    doc.xpath('//div[contains(text(), "$")]').each do |element_with_price|

      element_with_name = element_with_price.
        xpath("ancestor::table[1]").
        css('.highlight')

      lens = {
        name:           element_with_name.text,
        link:           element_with_name.first.attribute('href').text,
        aperture:       element_with_name.text[/\bf\/?[0-9.-]+/i],
        focal_length:   element_with_name.text[/[0-9.-]+mm/i],
        price:          element_with_price.text[/\$[0-9.]+/]
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
