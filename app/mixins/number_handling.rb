module NumberHandling
  def self.included(base)
  end

  # note see same in application helper

  def nil_to_0(value)
    if value == nil
      0
    else
      value
    end
  end

  def round_money (value)
    ((nil_to_0(value) * 100.0).round) / 100.0
  end

  def round_money_s (value)
    sprintf( "%.2f", nil_to_0(value) )
  end

  def round_places (value, places)
    _multiplier = 1.0
    places.times do |i|
      _multiplier *= 10
    end
    ((nil_to_0(value) * _multiplier).round) / _multiplier
  end

  def round_places_s (value, places)
    sprintf( "%." + places.to_s + "f", round_places(nil_to_0(value), places))
  end


end
