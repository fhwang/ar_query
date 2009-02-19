require 'rake'

Gem::Specification.new do |s|
  s.name = 'ar_query'
  s.version = '0.0.1'
  s.date = '2009-02-19'
  s.author = 'Francis Hwang'
  s.description = 'A utility class for building options for ActiveRecord.find.'
  s.summary = 'A utility class for building options for ActiveRecord.find.'
  s.email = 'sera@fhwang.net'
  s.homepage = 'http://github.com/fhwang/ar_query/tree/master'
  s.files = Rake::FileList['lib/*.rb']
end
