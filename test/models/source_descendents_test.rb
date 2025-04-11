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

  test "available_types returns sorted array of display names and classes" do
    original_method = Source.method(:descendants_with_names)

    begin
      Source.define_singleton_method(:descendants_with_names) do
        [
          [AnotherTestSourceSubclass.to_s, "Another Test Source"],
          [TestSourceSubclass.to_s, "Test Source"]
        ]
      end

      available_types = Source.available_types

      assert_equal 2, available_types.length
      assert_equal ["Another Test Source", AnotherTestSourceSubclass.to_s], available_types[0]
      assert_equal ["Test Source", TestSourceSubclass.to_s], available_types[1]
    ensure
      Source.define_singleton_method(:descendants_with_names, original_method)
    end
  end

  test "display_name raises NotImplementedError" do
    error = assert_raises(NotImplementedError) do
      Source.display_name
    end

    assert_match(/must implement class method display_name/, error.message)
  end

  test "descendants_with_names returns array of class names and display names" do
    descendants = Source.send(:descendants_with_names)

    assert_includes descendants.map(&:first), TestSourceSubclass.to_s
    assert_includes descendants.map(&:first), AnotherTestSourceSubclass.to_s

    test_subclass_entry = descendants.find { |entry| entry.first == TestSourceSubclass.to_s }
    assert_equal "Test Source", test_subclass_entry.last
  end

  test "descendants_including_self returns array of descendant classes" do
    descendants = Source.send(:descendants_including_self)

    assert_includes descendants, TestSourceSubclass
    assert_includes descendants, AnotherTestSourceSubclass
  end
end
