require "test_helper"
require "rexml/document"

class OaiImporterTest < ActiveSupport::TestCase
  setup do
    @importer = OaiImporter.new(create_source)
  end

  test "extract_ead returns ead element from metadata" do
    xml = REXML::Document.new(<<~XML).root
      <metadata>
        <ead xmlns="urn:isbn:1-931666-22-9">
          <archdesc level="collection">
            <did>
              <unitid>ABC123</unitid>
            </did>
          </archdesc>
        </ead>
      </metadata>
    XML

    ead_element = @importer.extract_ead(xml)

    assert_not_nil ead_element
    assert_equal "ead", ead_element.name
    assert_equal "collection", ead_element.elements["archdesc"].attributes["level"]
    assert_equal "ABC123", ead_element.elements["archdesc/did/unitid"].text
  end

  test "extract_ead handles different xpath for ead element" do
    xml = REXML::Document.new(<<~XML).root
      <root>
        <wrapper>
          <metadata>
            <something>else</something>
          </metadata>
          <ead>
            <archdesc level="fonds">
              <did>
                <unitid>XYZ789</unitid>
              </did>
            </archdesc>
          </ead>
        </wrapper>
      </root>
    XML

    ead_element = @importer.extract_ead(xml)

    assert_not_nil ead_element
    assert_equal "ead", ead_element.name
    assert_equal "fonds", ead_element.elements["archdesc"].attributes["level"]
    assert_equal "XYZ789", ead_element.elements["archdesc/did/unitid"].text
  end

  test "extract_ead returns nil when no ead element exists" do
    xml = REXML::Document.new(<<~XML).root
      <metadata>
        <not_ead>Some content</not_ead>
      </metadata>
    XML

    assert_nil @importer.extract_ead(xml)
  end

  test "extract_ead returns nil for nil input" do
    assert_nil @importer.extract_ead(nil)
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

  test "extract_repository_name returns nil for nil input" do
    assert_nil @importer.extract_repository_name(nil)
  end

  test "extract_repository_name returns nil when path doesn't exist" do
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
