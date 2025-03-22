require "test_helper"
require "rexml/document"

class OaiImporterTest < ActiveSupport::TestCase
  setup do
    @importer = OaiImporter.new(create_source)
  end

  test "extracts repository name from namespaced XML" do
    xml = REXML::Document.new(<<~XML).root
      <metadata>
        <ead xmlns="urn:isbn:1-931666-22-9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <archdesc level="collection">
            <did>
              <repository>
                <corpname>Allen Doe Research Center</corpname>
              </repository>
            </did>
          </archdesc>
        </ead>
      </metadata>
    XML

    assert_equal "Allen Doe Research Center", @importer.extract_repository_name(xml)
  end

  test "returns nil for nil input" do
    assert_nil @importer.extract_repository_name(nil)
  end

  test "returns nil when path doesn't exist" do
    xml = REXML::Document.new(<<~XML).root
      <metadata>
        <ead>
          <different>
            <structure>Test</structure>
          </different>
        </ead>
      </metadata>
    XML

    assert_nil @importer.extract_repository_name(xml)
  end

  test "parse_identifier extracts repository path" do
    assert_equal "/repositories/4", @importer.parse_identifier("oai:archivesspace:/repositories/4/resources/1")
    assert_equal "/repositories/12", @importer.parse_identifier("oai:archivesspace:/repositories/12/resources/42")
    assert_nil @importer.parse_identifier(nil)
    assert_nil @importer.parse_identifier("invalid:identifier")
  end
end
