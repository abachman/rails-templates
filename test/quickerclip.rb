module Paperclip
  class Geometry
    def self.from_file file
      parse("100x100")
    end
  end
  class Thumbnail
    def make
      src = Test::FileHelper.fixture_file('white_pixel.jpg')
      dst = Tempfile.new([@basename, @format].compact.join("."))
      dst.binmode
      FileUtils.cp(src.path, dst.path)
      return dst
    end
  end
end
