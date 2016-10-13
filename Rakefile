require 'dotenv/tasks'
require 'erb'
require 'mail'
require 'rake'
require 'ostruct'
require 'redcarpet'

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
    'https://github.com/SphereConsultingInc/weekly'
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

  def text
    source
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

  def markdown
    @md ||= Redcarpet::Markdown.new(HTMLwithPygments, fenced_code_blocks: true)
  end

  def clean?
    @clean
  end
end

CURRENT_ISSUE = 7

task :show => :dotenv do
  issue = Issue.new(CURRENT_ISSUE, true)
  File.open('/tmp/rebel-weekly.html', 'w') { |file| file.write(issue.html) }
  sh "open /tmp/rebel-weekly.html"
end

task :test => :dotenv do
  issue = Issue.new(CURRENT_ISSUE)

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
