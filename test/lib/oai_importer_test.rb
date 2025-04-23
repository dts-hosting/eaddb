require "test_helper"
require "rexml/document"

class OaiImporterTest < ActiveSupport::TestCase
  setup do
    @importer = OaiImporter.new(create_source)
  end

  {
    find_ead_identifier: {
      method_name: :find_ead_identifier,
      cases: [
        {
          name: "returns nil when xml_element is nil",
          xml: nil,
          expected: nil
        },
        {
          name: "returns existing eadid when present",
          xml: <<~XML,
            <ead>
              <eadheader>
                <eadid>existing-id</eadid>
              </eadheader>
            </ead>
          XML
          expected: "existing-id"
        },
        {
          name: "updates empty eadid with unitid value",
          xml: <<~XML,
            <ead>
              <eadheader>
                <eadid></eadid>
              </eadheader>
              <archdesc>
                <did>
                  <unitid>unit-id-value</unitid>
                </did>
              </archdesc>
            </ead>
          XML
          expected: "unit-id-value",
          post_check: ->(doc) { doc.elements["//eadheader/eadid"].text == "unit-id-value" }
        },
        {
          name: "creates eadid element when missing but unitid exists",
          xml: <<~XML,
            <ead>
              <eadheader>
                <!-- No eadid element here -->
              </eadheader>
              <archdesc>
                <did>
                  <unitid>new-unit-id</unitid>
                </did>
              </archdesc>
            </ead>
          XML
          expected: "new-unit-id",
          post_check: ->(doc) { doc.elements["//eadheader/eadid"].text == "new-unit-id" }
        },
        {
          name: "returns nil when both eadid and unitid are missing",
          xml: <<~XML,
            <ead>
              <eadheader>
                <!-- No eadid element -->
              </eadheader>
              <archdesc>
                <did>
                  <!-- No unitid element -->
                </did>
              </archdesc>
            </ead>
          XML
          expected: nil
        },
        {
          name: "returns nil when eadheader is missing",
          xml: <<~XML,
            <ead>
              <!-- No eadheader -->
              <archdesc>
                <did>
                  <unitid>orphaned-unit-id</unitid>
                </did>
              </archdesc>
            </ead>
          XML
          expected: nil
        }
      ]
    },
    extract_eadid: {
      method_name: :extract_eadid,
      cases: [
        {
          name: "returns value from eadheader/eadid element",
          xml: <<~XML,
            <metadata>
              <ead xmlns="urn:isbn:1-931666-22-9">
                <eadheader>
                  <eadid>MS-123</eadid>
                </eadheader>
                <archdesc level="collection">
                  <did><unitid>ABC123</unitid></did>
                </archdesc>
              </ead>
            </metadata>
          XML
          expected: "MS-123"
        },
        {
          name: "returns nil when eadid element doesn't exist",
          xml: <<~XML,
            <metadata>
              <ead xmlns="urn:isbn:1-931666-22-9">
                <eadheader>
                  <!-- No eadid element -->
                </eadheader>
              </ead>
            </metadata>
          XML
          expected: nil
        },
        {
          name: "returns nil for nil input",
          xml: nil,
          expected: nil
        }
      ]
    },
    extract_repository_name: {
      method_name: :extract_repository_name,
      cases: [
        {
          name: "extracts repository name from namespaced XML",
          xml: <<~XML,
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
          expected: "Allen Doe Research Center"
        },
        {
          name: "returns nil when path doesn't exist",
          xml: <<~XML,
            <metadata>
              <ead>
                <different>
                  <structure>Test</structure>
                </different>
              </ead>
            </metadata>
          XML
          expected: nil
        },
        {
          name: "returns nil for nil input",
          xml: nil,
          expected: nil
        }
      ]
    }
  }.each do |test_group_name, test_config|
    test_config[:cases].each do |test_case|
      test "#{test_config[:method_name]} #{test_case[:name]}" do
        xml = test_case[:xml].nil? ? nil : REXML::Document.new(test_case[:xml]).root
        result = @importer.send(test_config[:method_name], xml)

        if test_case[:expected].nil?
          assert_nil result
        else
          assert_equal test_case[:expected], result
        end

        if test_case[:post_check] && xml
          assert test_case[:post_check].call(xml), "Post-condition check failed"
        end
      end
    end
  end

  test "parse_identifier extracts repository path" do
    [
      {input: "oai:archivesspace:/repositories/4/resources/1", expected: "/repositories/4"},
      {input: "oai:archivesspace:/repositories/12/resources/42", expected: "/repositories/12"},
      {input: nil, expected: nil},
      {input: "invalid:identifier", expected: nil}
    ].each do |test_case|
      result = @importer.send(:parse_identifier, test_case[:input])

      if test_case[:expected].nil?
        assert_nil result
      else
        assert_equal test_case[:expected], result
      end
    end
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

    ead_element = @importer.send(:extract_ead, xml)

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

    ead_element = @importer.send(:extract_ead, xml)

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

    assert_nil @importer.send(:extract_ead, xml)
  end

  test "extract_ead returns nil for nil input" do
    assert_nil @importer.send(:extract_ead, nil)
  end
end
