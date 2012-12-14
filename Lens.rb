class Lens

  def initialize(attrs)
    @lens = attrs
    @lens.merge!({
      aperture:     attrs[:name][/\bf\/?[0-9.-]+/i],
      focal_length: attrs[:name][/[0-9.-]+mm/i],
      price:        attrs[:price][/\$[0-9.]+/]
    })

    # Only care about proper lenses (not teleconverters, etc.)
    puts @lens
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


  # TODO: DRY up these 2 methods
  # Find minimum and maximum aperture
  def split_aperture!
    parts = @lens[:aperture].scan(/f([0-9.]+)-([0-9.]+)/i).flatten
    if parts.any?
      @lens[:aperture_min] = parts.first
      @lens[:aperture_max] = parts.last
    elsif aperture = @lens[:aperture][/[0-9.]+/]
      @lens[:aperture_min] = @lens[:aperture_max] = aperture
    end
  end


  # Find minimum and maximum focal length
  def split_focal_length!
    parts = @lens[:focal_length].scan(/([0-9.]+)-([0-9.]+)mm/i).flatten
    if parts.any?
      @lens[:focal_length_min] = parts.first
      @lens[:focal_length_max] = parts.last
    elsif focal_length = @lens[:focal_length][/[0-9.]+/]
      @lens[:focal_length_min] = @lens[:focal_length_max] = focal_length
    end
  end


  # Generate coordinates of points to plot on a chart
  def generate_plot!
    min = [@lens[:focal_length_min], @lens[:aperture_min] ]
    max = [@lens[:focal_length_max], @lens[:aperture_max] ]
    @lens[:plot] = min == max ? [min] : [min, max]
  end

end
