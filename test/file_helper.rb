module Test
  class FileHelper
    def self.fixture_file(path)
      @@test_file_helper_file_descriptors ||= {}
      @@test_file_helper_file_descriptors[path] ||=
        File.new(File.join(RAILS_ROOT, 'test', 'fixtures', path))
    end
  end
end
