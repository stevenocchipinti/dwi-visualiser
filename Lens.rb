#
# This class should be instatiated with a :name, :price, :link and :image
#
# Hash representation:
# lens.to_json #=> {
#   "aperture": "F4-5.6",
#   "aperture_max": "5.6",
#   "aperture_min": "4",
#   "focal_length": "10-20mm",
#   "focal_length_max": "20",
#   "focal_length_min": "10",
#   "image": "...",
#   "link": "...",
#   "name": "Sigma 10-20mm F4-5.6 EX DC HSM Lenses",
#   "plot": [ ["10","4"], ["20","5.6"] ],
#   "price": "$411.00"
# }
#

class Lens

  def initialize(attrs)
    @lens = attrs
    parse_name_and_price!
    generate_plot!
  end


  def to_json(*opts)
    @lens.to_json(*opts)
  end


  private


  # Extract useful data from the name
  def parse_name_and_price!
    @lens.merge!({
      aperture:     @lens[:name][/\bf\/?[0-9.-]+/i],
      focal_length: @lens[:name][/[0-9.-]+mm/i],
      price:        @lens[:price][/\$[0-9.]+/]
    })

    # Only care about proper lenses (not teleconverters, etc.)
    if !@lens[:focal_length] || !@lens[:aperture]
      raise "Must have a focal length and an aperture"
    end

    split_range!(:aperture, /f([0-9.]+)-([0-9.]+)/i)
    split_range!(:focal_length, /([0-9.]+)-([0-9.]+)mm/i)
  end


  def split_range!(key, regex)
    parts = @lens[key].scan(regex).flatten
    if parts.any?
      @lens["#{key}_min".to_sym] = parts.first
      @lens["#{key}_max".to_sym] = parts.last
    elsif only_element = @lens[key][/[0-9.]+/]
      @lens["#{key}_min".to_sym] = @lens["#{key}_max".to_sym] = only_element
    end
  end


  # Generate coordinates of points to plot on a chart
  def generate_plot!
    min = [@lens[:focal_length_min], @lens[:aperture_min] ]
    max = [@lens[:focal_length_max], @lens[:aperture_max] ]
    @lens[:plot] = min == max ? [min] : [min, max]
  end

end
