module Importers
  module Ead
    XPATH_FOR_EADHEADER = "//eadheader"
    XPATH_FOR_EADID = "//eadheader/eadid"
    XPATH_FOR_REPOSITORY_NAME = "//repository/corpname"
    XPATH_FOR_ROOT = "//ead"
    XPATH_FOR_UNITID = "//ead/archdesc/did/unitid"

    def extract_ead(xml_element)
      return if xml_element.nil?

      xml_element.elements[XPATH_FOR_ROOT]
    end

    def extract_eadid(xml_element)
      xml_text_value(xml_element, XPATH_FOR_EADID)
    end

    def extract_repository_name(xml_element)
      xml_text_value(xml_element, XPATH_FOR_REPOSITORY_NAME)
    end

    def find_ead_identifier(xml_element)
      return if xml_element.nil?

      eadid = extract_eadid(xml_element)
      return eadid if eadid

      unitid = xml_text_value(xml_element, XPATH_FOR_UNITID)
      eadid_element = REXML::XPath.first(xml_element, XPATH_FOR_EADID)

      if unitid && eadid_element
        eadid_element.text = unitid
      elsif unitid
        eadheader = REXML::XPath.first(xml_element, XPATH_FOR_EADHEADER)
        if eadheader
          eadid_element = REXML::Element.new("eadid")
          eadid_element.text = unitid
          eadheader.add_element(eadid_element)
        else
          return nil
        end
      end

      unitid
    end

    def xml_text_value(xml_element, xpath)
      return if xml_element.nil?

      REXML::XPath.first(xml_element, xpath)&.text
    end

    def xml_to_string(xml_element)
      return if xml_element.nil?

      xml = ""
      formatter = REXML::Formatters::Pretty.new(0)
      formatter.compact = true
      formatter.write(xml_element, xml)
    end
  end
end
