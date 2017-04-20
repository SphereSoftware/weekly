require_relative "lib/all"

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
  Weekly.new(current_issue).build
end


task default: %w[build]

class Redcarpet::Markdown
  attr_accessor :issue_object

  def new_render(src)
    @renderer.issue_object = issue_object
    render(src)
  end
end
