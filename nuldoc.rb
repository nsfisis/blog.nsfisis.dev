require 'date'
require 'digest/md5'
require 'fileutils'

require 'asciidoctor'

require_relative 'lib/command'
require_relative 'lib/html_converter'
require_relative 'lib/parser'
require_relative 'lib/extensions/document_title_processor'
require_relative 'lib/extensions/lang_attribute_processor'
require_relative 'lib/extensions/revision_history_processor'
require_relative 'lib/extensions/section_id_validator'
require_relative 'lib/extensions/source_id_processor'
require_relative 'lib/extensions/source_id_validator'
require_relative 'lib/extensions/tags_processor'
require_relative 'lib/revision'
require_relative 'lib/tag'

NulDoc::Command.new({
  author: 'nsfisis',
  site_name: 'REPL: Rest-Eat-Program Loop',
  site_copyright_year: 2021,
  content_dir: __dir__ + '/content',
  dest_dir: __dir__ + '/public',
  static_dir: __dir__ + '/static',
  template_dir: __dir__ + '/templates',
}).run
