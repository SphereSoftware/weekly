class Weekly
  attr_reader :current_issue

  def initialize(current_issue)
    @current_issue = current_issue
  end

  def all
    @all ||= Dir[ROOT_PATH + "/{2016,2017,2018,2019}/**/*.md"].map do |path|
      url = path.
        gsub(ROOT_PATH, "").
        gsub("/README.md", "")

      year = url.split('/')[1]

      Issue.new(path: path, url: url, year: year)
    end
  end

  def build
    all.map(&:build)
    all.last.build_index
    ArchivePage.new(all).build
  end
end
