require 'dotenv/tasks'
require 'erb'
require 'mail'
require 'rake'
require 'ostruct'
require 'redcarpet'
require 'fileutils'

ROOT_PATH = File.dirname(File.dirname(__FILE__))
ISSUE_TEMPLATE = ERB.new(File.open(ROOT_PATH + "/issue.html.erb").readlines.join)
INDEX_TEMPLATE = ERB.new(File.open(ROOT_PATH + "/index.html.erb").readlines.join)
ARCHIVE_TEMPLATE = ERB.new(File.open(ROOT_PATH + "/archives.html.erb").readlines.join)

require_relative "renderer"
require_relative "issue"
require_relative "archive_page"
require_relative "weekly"
