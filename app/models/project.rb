class Project < ActiveRecord::Base
  def records
    # ... Fancy arel query here based on uploaded file!
    # ... and push data into the plain old ruby object
    #
    # IE:
    # records = "SELECT * FROM data_#{project.uniq_data}".collect{|row| GenericRecord.new(result)}
    #
    # TODO investigate postgres JSON data types or creating this schema on the fly.
    [
      GenericRecord.new(id: 1, name: "Peter", description: "Griffin", the_geom: nil, image_url: "https://pbs.twimg.com/profile_images/1119269505/0509071614Peter_Griffin.jpg"),
      GenericRecord.new(id: 2, name: "Glenn", description: "Quagmire", the_geom: nil, image_url: nil),
    ]
  end
end

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