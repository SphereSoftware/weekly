require 'dotenv/tasks'
require 'erb'
require 'mail'
require 'rake'
require 'ostruct'
require 'redcarpet'
require 'fileutils'

class HTMLwithPygments < Redcarpet::Render::HTML
  def block_code(code, language)
    Pygments.highlight(code, lexer: language)
  end
end

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

  def html
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
  File.open('/tmp/rebel-weekly.html', 'w') { |file| file.write(issue.html) }
  sh "open /tmp/rebel-weekly.html"
end

task :test => :dotenv do
  issue = Issue.new(current_issue)

  options = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => 'sphereinc.com',
    :user_name            => ENV['USERNAME'],
    :password             => ENV['PASSWORD'],
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }

  Mail.defaults do
    delivery_method :smtp, options
  end

  Mail.deliver do
    # to 'all-employees@sphereinc.com'
    to 'ashemerey@sphereinc.com'
    from ENV['USERNAME']
    from "Rebel Weekly <#{ENV['USERNAME']}>"
    subject "🌟 Rebel Weekly 🌟 ##{"%03d" % issue.id}"

    text_part do
      body issue.text
    end

    html_part do
      content_type 'text/html; charset=UTF-8'
      body issue.html
    end
  end
end

task default: %w[show]
