require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rspec'
require 'spf_parse'

include SPFParse

RSpec.configure do |specs|
  specs
end