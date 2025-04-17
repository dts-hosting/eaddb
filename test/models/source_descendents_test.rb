# test/models/source_descendents_test.rb

require "test_helper"

class SourceDescendentsTest < ActiveSupport::TestCase
  class TestSourceSubclass < Source
    def self.display_name
      "Test Source"
    end

    def build_validation_url
      "http://example.com"
    end

    def client
      nil
    end

    def run
      nil
    end
  end

  class AnotherTestSourceSubclass < Source
    def self.display_name
      "Another Test Source"
    end

    def build_validation_url
      "http://example.com"
    end

    def client
      nil
    end

    def run
      nil
    end
  end

  test "display_name raises NotImplementedError" do
    error = assert_raises(NotImplementedError) do
      Source.display_name
    end

    assert_match(/must implement class method display_name/, error.message)
  end

  test "descendants_by_display_name returns hash of display names to class names" do
    descendants = Source.descendants_by_display_name

    assert_includes descendants.values, TestSourceSubclass.to_s
    assert_includes descendants.values, AnotherTestSourceSubclass.to_s

    assert_includes descendants.keys, "Test Source"
    assert_includes descendants.keys, "Another Test Source"

    assert_equal TestSourceSubclass.to_s, descendants["Test Source"]
    assert_equal AnotherTestSourceSubclass.to_s, descendants["Another Test Source"]
  end
end
