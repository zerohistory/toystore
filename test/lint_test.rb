$:.unshift(File.expand_path('../../lib', __FILE__))
require 'toy'

class User
  include Toy::Store
end

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = User.new
  end
end