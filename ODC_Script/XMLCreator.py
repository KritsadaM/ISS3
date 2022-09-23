"""The XML generator library for Celestica's shopfloor control system."""

import lxml.etree as xml_creator


class XMLCreator(object):
    """The XML gemerator library for Celestica's shopfloor control system."""

    def __init__(self):
        self.root = xml_creator.Element('test')
        self.fail_root = xml_creator.Element('failure')
        self.par_root = xml_creator.Element('parameter')
        self.fail_code = None

    def add_node(self, node_name, node_value, node_attr_name=None,
                 node_attr_value=None):
        """Add XML node.

        Add the XML node attribute to the XML string.

        Args:
          node_name: XML node name that will be added.
          node_value: The value of the XML node.
          node_attr_name: Node attribute name.
          node_attr_value: Node attribute value.

        Returns:
          None

        Raise:
          None
        """
        child = xml_creator.Element(node_name)
        if node_attr_name is not None:
            child.set(node_attr_name, node_attr_value)
        child.text = node_value
        self.root.append(child)

    def get_xml_data(self):
        """Retrieve the XML data string.

        Retrieve the XML data string in one line.

        Args:
          None.

        Returns:
          None.

        Raise:
          None.
        """
        return xml_creator.tostring(self.root, xml_declaration=True,
                                    encoding='UTF-8')

    def print_xml_data(self):
        """Retrieve the XML data in pretty format.

        This function will return the pretty print format of the XML data.
        It will easy to read by the human.

        Args:
          None.

        Returns:
          None.

        Raise:
          None.
        """
        return xml_creator.tostring(self.root, pretty_print=True,
                                    xml_declaration=True, encoding='UTF-8')

    def set_failure_code(self, code):
        """Add failure code XML data.

        Add the failure code to the XML data format.

        Args:
          code: Failure code.

        Returns:
          None.

        Raise:
          None.
        """
        self.fail_code = xml_creator.Element('failcode')
        self.fail_code.set("code", code)
        self.fail_root.append(self.fail_code)

    def set_failure_data(self, description, parameter=None):
        """Add failure detail.

        Add the failure description to the XML data format.

        Args:
          description: Failure description.
          parameter: Failure parameter.

        Returns:
          None.

        Raise:
          None.
        """
        des_node = xml_creator.Element('description')
        des_node.text = description
        self.fail_code.append(des_node)
        parameter_root = xml_creator.Element('parameter')
        if parameter is not None:
            parameter = parameter.split(', ')
            fail_parameter = parameter[1:]
            for failXml in fail_parameter:
                fail_param_attr = xml_creator.Element('par')
                fail_param_attr.set("name", "Fail Step")
                fail_param_attr.text = failXml
                parameter_root.append(fail_param_attr)
            self.fail_root.append(parameter_root)
        self.root.append(self.fail_root)

    def set_parameter(self):
        """Add the parameter to the root node.

        Add the parameter to the root node.

        Args:
          None.

        Returns:
          None.

        Raise:
          None.
        """
        self.root.append(self.par_root)

    def add_par_node(self, par_name, value=None):
        """Add new parameter node.

        Add new parameter node.

        Args:
          par_name: Parameter node name.
          value: Parameter node value.

        Returns:
          None.

        Raise:
          None.
        """
        self.par_node = xml_creator.Element('par')
        self.par_node.set('name', par_name)
        if value is not None:
            self.par_node.text = value
        self.par_root.append(self.par_node)

    def clear_xml_data(self):
        """Delete the XML data on all node.

        Delete the XML data on all node.

        Args:
          None.

        Returns:
          None.

        Raise:
          None.
        """
        self.root = None
        self.fail_root = None
        self.root = xml_creator.Element('test')
        self.fail_root = xml_creator.Element('failure')

    def write_to_file(self, file_name):
        """Write the XML data to file.

        Write the XML data to file.

        Args:
          file_name: Output file name including file path.

        Returns:
          None.

        Raise:
          None.
        """
        file_desc = open(file_name, 'a')
        file_desc.write(xml_creator.tostring(self.root))
        file_desc.close()
