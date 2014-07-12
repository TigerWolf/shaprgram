class GenericRecord
  def initialize(data)
    @data = data
  end

  def column_names
    @data.keys
  end

  def data
    @data
  end
end