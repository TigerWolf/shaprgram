require 'open-uri'
class Photo < ActiveRecord::Base

  belongs_to :item

  has_attached_file :image,
    path: "public/system/photos/:id/:name_:style:retina.:extension",
    url:  "/system/photos/:id/:name_:style:retina.:extension",
    styles: { 
              thumb:     ["180x180>",  :jpg],
              thumb_2x:  ["360x360>",  :jpg],
              large:     ["624x416\\>",  :jpg],
              large_2x:  ["1248X832\\>", :jpg]
            },
    convert_options: {
              large:    '-background "#f6f6f6" -gravity center -extent 624x416',
              large_2x: '-background "#f6f6f6" -gravity center -extent 1248X832'
           }

  validates_attachment_presence :image
  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png"] }

  def image_from_url(url)
    self.image = open(url)
  end

  def image_from_file(file)
    self.image = File.new(file, 'r')
  end

  Paperclip.interpolates :style do |attachment, style|
    style.to_s.end_with?('_2x') ? style.to_s[0..-4] : style
  end

  Paperclip.interpolates :retina do |attachment, style|
    style.to_s.end_with?('_2x') ? '@2x' : ''
  end

  Paperclip.interpolates :name do |a, s|
    a.instance.image_file_name.gsub(/\.\w{3,4}$/, '')
  end

end
