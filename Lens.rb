class Lens

  def initialize(attrs)
    @lens = attrs
    @lens.merge!({
      aperture:     attrs[:name][/\bf\/?[0-9.-]+/i],
      focal_length: attrs[:name][/[0-9.-]+mm/i],
      price:        attrs[:price][/\$[0-9.]+/]
    })

    # Only care about proper lenses (not teleconverters, etc.)
    if !@lens[:focal_length] || !@lens[:aperture]
      raise "Must have a focal length and an aperture"
    end

    split_focal_length!
    split_aperture!
    generate_plot!
  end


  def to_json(*opts)
    @lens.to_json(*opts)
  end


  private


  # Find minimum and maximum aperture
  def split_aperture!
    split_range!(:aperture, /f([0-9.]+)-([0-9.]+)/i)
  end


  # Find minimum and maximum focal length
  def split_focal_length!
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
