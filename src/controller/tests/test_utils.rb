require 'minitest/autorun'
dir = File.dirname(__FILE__)
require "#{dir}/../lib/utils"

class TestUtils < Minitest::Test
  def test_addslashes
    assert addslashes(nil) == ''
    assert addslashes(false) == ''
    assert addslashes(' \ ') == ' \\\ '
    assert addslashes(" ' ") == " \\' "
    assert addslashes(' " ') == ' \\" '
  end
end