class ArchivePage
  attr_reader :issues
  def initialize(issues)
    @issues = issues
  end

  def html
    ARCHIVE_TEMPLATE.result(binding)
  end

  def build
    File.open("#{ROOT_PATH}/docs/archive.html", 'w') { |file| file.write(html) }
    puts 'Archive page builded'
  end
end
