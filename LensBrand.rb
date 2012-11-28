require 'nokogiri'
require 'open-uri'
require 'json'

class LensBrand

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

      hash = {
        name:           element_with_name.text,
        link:           element_with_name.first.attribute('href').text,
        aperture:       element_with_name.text[/f[0-9.-]+/i],
        focal_length:   element_with_name.text[/[0-9.-]+mm/i],
        price:          element_with_price.text[/\$[0-9.]+/]
      }

      if hash[:aperture]
        parts = hash[:aperture].scan(/f([0-9.]+)-([0-9.]+)/i).flatten
        if parts.any?
          hash[:aperture_min] = parts.first
          hash[:aperture_max] = parts.last
        elsif aperture = hash[:aperture][/[0-9.]+/]
          hash[:aperture_min] = hash[:aperture_max] = aperture
        end
      end

      if hash[:focal_length]
        parts = hash[:focal_length].scan(/([0-9.]+)-([0-9.]+)mm/i).flatten
        if parts.any?
          hash[:focal_length_min] = parts.first
          hash[:focal_length_max] = parts.last
        elsif focal_length = hash[:focal_length][/[0-9.]+/]
          hash[:focal_length_min] = hash[:focal_length_max] = focal_length
        end
      end

      min = [hash[:focal_length_min], hash[:aperture_min] ]
      max = [hash[:focal_length_max], hash[:aperture_max] ]
      hash[:plot] = min == max ? [min] : [min, max]

      lenses << hash

    end

    lenses
  end

end
