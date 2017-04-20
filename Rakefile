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
  def block_code(code, language)
    Pygments.highlight(code, lexer: language)
  end

  def paragraph(text)
    require 'pry'; binding.pry unless Thread.current[:request_store].object_id == $_current_request_id
  end
end


class Issue
  attr_reader :path, :url, :year
  def initialize(path: path, url: url, year: year)
    @path = path
    @url = url
    @year = year
  end

  def build
    puts html
    # File.open("#{File.dirname(__FILE__)}/docs/index.html", 'w') { |file| file.write(content) }
    # system("open #{File.dirname(__FILE__)}/docs/index.html")
  end

  def content
    @issue_content ||= begin
      markdown.render(source)
    end
  end

  def markdown
    @md ||= Redcarpet::Markdown.new(HTMLwithPygments, fenced_code_blocks: true)
  end

  def source
    File.open(path).readlines.join
  end

  def html
    ISSUE_TEMPLATE.result(binding)
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
    # puts all.map(&:build)
    puts all.first.build
  end
end
