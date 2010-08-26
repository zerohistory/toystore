class NameAndNumberKeyFactory < Toy::Identity::AbstractKeyFactory
  def next_key(object)
    "#{object.name}-#{object.number}" unless object.name.nil? || object.number.nil?
  end
end