class Renderer < Redcarpet::Render::HTML
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
