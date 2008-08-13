require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require File.join(File.dirname(__FILE__), '../init.rb')

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:stringify_date_format => '%d/%m/%Y')

class Person < ActiveRecord::Base
  attr_accessor :born_on
  stringify_date :born_on
end

class StringifyDateTest < Test::Unit::TestCase
  
  def test_basic
    p = Person.new(:born_on => Date.new(2000,1,1))
    p.born_on_string = "2/2/2002"
    assert_equal(Date.new(2002,2,2), p.born_on)
  end
end
