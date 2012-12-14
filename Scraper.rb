# TODO: Should this be a lens class instead of a Scraper module
#       The class could be instantiated with a name string and a price

module Scraper

  def get_lenses(url)
    # TODO: Is this necessary?
    raise "All Scrapers should implement this!"
  end

  # TODO: DRY up these 2 methods
  # Find minimum and maximum aperture
  def split_aperture!(lens)
    parts = lens[:aperture].scan(/f([0-9.]+)-([0-9.]+)/i).flatten
    if parts.any?
      lens[:aperture_min] = parts.first
      lens[:aperture_max] = parts.last
    elsif aperture = lens[:aperture][/[0-9.]+/]
      lens[:aperture_min] = lens[:aperture_max] = aperture
    end
  end

  # Find minimum and maximum focal length
  def split_focal_length!(lens)
    parts = lens[:focal_length].scan(/([0-9.]+)-([0-9.]+)mm/i).flatten
    if parts.any?
      lens[:focal_length_min] = parts.first
      lens[:focal_length_max] = parts.last
    elsif focal_length = lens[:focal_length][/[0-9.]+/]
      lens[:focal_length_min] = lens[:focal_length_max] = focal_length
    end
  end

  # Generate coordinates of points to plot on a chart
  def generate_plot!(lens)
    min = [lens[:focal_length_min], lens[:aperture_min] ]
    max = [lens[:focal_length_max], lens[:aperture_max] ]
    lens[:plot] = min == max ? [min] : [min, max]
  end

end
