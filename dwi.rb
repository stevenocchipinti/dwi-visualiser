require 'nokogiri'
require 'open-uri'

# Find the element with the pricetag
# Asend up the DOM until the containing table element is found
# Descend down the DOM until the link with the 'highlight' class is found
#   This element contains the description (with focal length and aperture)

doc = Nokogiri::HTML(open('http://www.dwidigitalcameras.com.au/astore/Sigma-Lenses.aspx'))

lenses = []
doc.xpath('//div[contains(text(), "$")]').each do |element_with_price|
  element_with_name = element_with_price.
    xpath("ancestor-or-self::table[1]").
    css('.highlight')

  hash                = {}
  hash[:name]         = element_with_name.text
  hash[:link]         = element_with_name.first.attribute('href').text
  hash[:price]        = element_with_price.text[/\$[0-9.]+/]
  hash[:aperture]     = hash[:name][/f[0-9.-]+/i]
  hash[:focal_length] = hash[:name][/[0-9.-]+mm/i]
  lenses << hash
end

puts lenses.to_yaml
