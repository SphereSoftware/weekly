class Issue
  attr_reader :path, :url, :year
  attr_accessor :links

  def initialize(path: path, url: url, year: year)
    @links = []
    @path = path
    @url = url
    @year = year
  end

  def build_index
    File.open("#{ROOT_PATH}/docs/index.html", 'w') { |file| file.write(index_html) }
  end

  def id
    url.split('-').last
  end

  def data
    @data ||= File.ctime(path)
  end

  def inspect
    {path: path, url: url, year: year, data: data, id: id, links: links}
  end

  def build
    FileUtils.mkdir_p "#{ROOT_PATH}/docs/#{url}/"
    File.open("#{ROOT_PATH}/docs/#{url}/index.html", 'w') { |file| file.write(html) }
    puts url
    # system("open #{ROOT_PATH}/docs/#{url}/index.html")
  end

  def content
    markdown.new_render(source)
  end

  def markdown
    @md ||= begin
      Redcarpet::Markdown.new(::Renderer, fenced_code_blocks: true).tap do |obj|
        obj.issue_object = self
      end
    end
  end

  def source
    File.open(path).readlines.join
  end

  def index_html
    INDEX_TEMPLATE.result(binding)
  end

  def html
    ISSUE_TEMPLATE.result(binding)
  end
end
