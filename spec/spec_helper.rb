if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rspec'
require 'spf_parse'

include SPFParse

RSpec.configure do |specs|
  specs
end
