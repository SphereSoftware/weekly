require 'erb'
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

  def initialize(id)
    @id = id
  end

  def url
    'https://github.com/SphereConsultingInc/weekly'
  end

  def name
    'Rebel Weekly'
  end

  def content
    @issue_content ||= begin
      file = File.open(issue_file_path).readlines.join
      markdown.render(file)
    end
  end

  def issue_file_path
    File.dirname(__FILE__) + "/#{Date.today.year}/issue-#{"%03d" % id}/README.md"
  end

  def render
    email_template.result(binding)
  end

  private

  def email_template
    ERB.new(File.open(File.dirname(__FILE__) + "/email.html.erb").readlines.join)
  end

  def markdown
    @md ||= Redcarpet::Markdown.new(HTMLwithPygments, fenced_code_blocks: true)
  end

end


task :show do
  issue = Issue.new(1)
  File.open('/tmp/rebel-weekly.html', 'w') { |file| file.write(issue.render) }
  sh "open /tmp/rebel-weekly.html"
end

task default: %w[show]
