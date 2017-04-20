require 'dotenv/tasks'
require 'erb'
require 'mail'
require 'rake'
require 'ostruct'
require 'redcarpet'
require 'fileutils'


=begin
class Issue
  attr_reader :id

  def initialize(id, clean = false)
    @id = id
    @clean = clean
  end

  def url
    'https://github.com/SphereSoftware/weekly'
  end

  def name
    'Sphere Rebel Weekly'
  end

  def content
    @issue_content ||= begin
      markdown.render(source)
    end
  end

  def issue_file_path
    File.dirname(__FILE__) + "/#{Date.today.year}/issue-#{"%03d" % id}/README.md"
  end

  def index
    index_template.result(binding)
  end

  def email
    email_template.result(binding)
  end

  def template
    issue_template.result(binding)
  end

  def text
    source
  end

  def dir_path
    "#{Date.today.year}/issue-%03d" % id
  end

  private

  def source
    File.open(issue_file_path).readlines.join
  end

  def index_template
      ERB.new(File.open(File.dirname(__FILE__) + "/issue.html.erb").readlines.join)
  end

  def email_template
    if clean?
      ERB.new("<%= content %>")
    else
      ERB.new(File.open(File.dirname(__FILE__) + "/email.html.erb").readlines.join)
    end
  end

  def issue_template
    ERB.new(File.open(File.dirname(__FILE__) + "/issue-template.md").readlines.join)
  end

  def markdown
    @md ||= Redcarpet::Markdown.new(HTMLwithPygments, fenced_code_blocks: true)
  end

  def clean?
    @clean
  end
end
=end

def current_issue
  Dir['*/issue*'].last.split('-').last.to_i
end

task :new => :dotenv do
  next_issue_number = current_issue + 1
  issue = Issue.new(next_issue_number, true)

  # create directory is needed
  unless File.directory?(issue.dir_path)
    FileUtils.mkdir_p(issue.dir_path)
  end

  # write a file
  File.open(issue.issue_file_path, 'w') do |file|
    file.write(issue.template)
  end

  # link the issue
  current_file = File.dirname(__FILE__) + '/current.md'
  FileUtils.rm_f(current_file) if File.exist?(current_file) || File.symlink?(current_file)
  FileUtils.symlink(issue.issue_file_path, current_file)

  # puts issue.default_md
  puts current_issue, 'created 🎉🍻'
end

task :show => :dotenv do
  issue = Issue.new(current_issue, true)
  File.open('/tmp/rebel-weekly.html', 'w') { |file| file.write(issue.email) }
  sh "open /tmp/rebel-weekly.html"
end

task :build => :dotenv do
  weekly = Weekly.new(current_issue)
  weekly.build
  # issue = Issue.new(current_issue, true)
  # issue.build
  # File.open("#{File.dirname(__FILE__)}/docs/index.html", 'w') { |file| file.write(issue.index) }
  # sh "open /tmp/rebel-weekly.html"
end


task default: %w[build]

ISSUE_TEMPLATE = ERB.new(File.open(File.dirname(__FILE__) + "/issue.html.erb").readlines.join)
INDEX_TEMPLATE = ERB.new(File.open(File.dirname(__FILE__) + "/index.html.erb").readlines.join)
ARCHIVE_TEMPLATE = ERB.new(File.open(File.dirname(__FILE__) + "/archives.html.erb").readlines.join)

class HTMLwithPygments < Redcarpet::Render::HTML
  attr_accessor :issue_object

  def block_code(code, language)
    Pygments.highlight(code, lexer: language)
  end

  def header(text, header_level)
    if header_level == 1
      <<-HTML
      <div class="title-item">
        <h1>#{text}</h1>
      </div>
      HTML
    else
      <<-HTMLW
      <h#{header_level}>#{text}</h#{header_level}>
      HTMLW
    end
  end

  def paragraph(text)
    text
  end

  def list_item(text, list_type)
    self.issue_object.links.push(text)
    "<li>#{text}</li>"
  end
end


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
    File.open("#{File.dirname(__FILE__)}/docs/index.html", 'w') { |file| file.write(index_html) }
  end

  def id
    url.split('-').last
  end

  def inspect
    {path: path, url: url, year: year, data: File.ctime(path), id: id, links: links}
  end

  def build
    FileUtils.mkdir_p "#{File.dirname(__FILE__)}/docs/#{url}/"
    File.open("#{File.dirname(__FILE__)}/docs/#{url}/index.html", 'w') { |file| file.write(html) }
    puts url
    # system("open #{File.dirname(__FILE__)}/docs/#{url}/index.html")
  end

  def content
    markdown.new_render(source)
  end

  def markdown
    @md ||= begin
      md = Redcarpet::Markdown.new(HTMLwithPygments, fenced_code_blocks: true)
      md.issue_object = self
      md
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

class ArchivePage
  attr_reader :issues
  def initialize(issues)
    @issues = issues
  end

  def html
    ARCHIVE_TEMPLATE.result(binding)
  end

  def build
    require 'pry'; binding.pry unless Thread.current[:request_store].object_id == $_current_request_id
    File.open("#{File.dirname(__FILE__)}/docs/archive.html", 'w') { |file| file.write(html) }
    puts 'Archive page builded'
  end
end

class Redcarpet::Markdown
  attr_accessor :issue_object

  def new_render(src)
    @renderer.issue_object = issue_object
    render(src)
  end
end

class Weekly
  attr_reader :current_issue

  def initialize(current_issue)
    @current_issue = current_issue
  end

  def all
    Dir[File.dirname(__FILE__) + "/{2016,2017,2018,2019}/**/*.md"].map do |path|
      url = path.
        gsub(File.dirname(__FILE__), "").
        gsub("/README.md", "")

      year = url.split('/')[1]

      Issue.new(path: path, url: url, year: year)
    end
  end

  def build
    all.map(&:build)
    all.last.build_index
    require 'pry'; binding.pry unless Thread.current[:request_store].object_id == $_current_request_id
    ArchivePage.new(all).build
  end
end
