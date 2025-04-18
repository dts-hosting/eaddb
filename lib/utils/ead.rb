module Utils
  module Ead
    def ensure_eadid(xml_element)
      return if xml_element.nil?

      eadid = extract_eadid(xml_element)
      return eadid if eadid

      unitid = xml_text_value(xml_element, "//ead/archdesc/did/unitid")
      return nil if unitid.nil?

      eadid_element = REXML::XPath.first(xml_element, "//eadheader/eadid")

      if eadid_element
        eadid_element.text = unitid
      else
        eadheader = REXML::XPath.first(xml_element, "//eadheader")
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

    def extract_ead(xml_element)
      return if xml_element.nil?

      xml_element.elements["/metadata/ead"] || xml_element.elements["//ead"]
    end

    def extract_eadid(xml_element)
      xml_text_value(xml_element, "//eadheader/eadid")
    end

    def extract_repository_name(xml_element)
      xml_text_value(xml_element, "//repository/corpname")
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
