if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rspec'
require 'spf/query'

include SPF::Query

RSpec.configure do |specs|
  specs
end
