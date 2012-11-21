require 'nokogiri'
require 'open-uri'

# Find the element with the pricetag
# Asend up the DOM until the containing table element is found
# Descend down the DOM until the link with the 'highlight' class is found
#   This element contains the description (with focal length and aperture)

#url = 'http://www.dwidigitalcameras.com.au/astore/Sigma-Lenses.aspx'
url = 'Sigma-Lenses.aspx'

doc = Nokogiri::HTML(open(url))

lenses = []
doc.xpath('//div[contains(text(), "$")]').each do |element_with_price|

  element_with_name = element_with_price.
    xpath("ancestor::table[1]").
    css('.highlight')

  hash                = {}
  hash[:name]         = element_with_name.text
  hash[:link]         = element_with_name.first.attribute('href').text
  hash[:price]        = element_with_price.text[/\$[0-9.]+/]

  if hash[:aperture] = hash[:name][/f[0-9.-]+/i]
    parts = hash[:aperture].scan(/f([0-9.]+)-([0-9.]+)/i).flatten
    if parts.any?
      hash[:aperture_min] = "F#{parts.first}"
      hash[:aperture_max] = "F#{parts.last}"
    end
  end

  if hash[:focal_length] = hash[:name][/[0-9.-]+mm/i]
    parts = hash[:focal_length].scan(/([0-9.]+)-([0-9.]+)mm/i).flatten
    if parts.any?
      hash[:focal_length_min] = "#{parts.first}mm"
      hash[:focal_length_max] = "#{parts.last}mm"
    end
  end

  lenses << hash

end

puts lenses.to_yaml
