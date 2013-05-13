class Time
  def to_msgpack(*args)
    to_i.to_msgpack(*args)
  end
end
