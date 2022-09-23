"""Interface library for Celestica's shopfloor control."""

import http.client


class ODCServer(object):
    """The main interface library to communicate with Celestica's shopfloor."""
    def __init__(self, shopfloor_url, business_unit):
        """Initialize.

        Initial shopfloor control variable.

        Args:
          shopfloor_url: Shopfloor URL string.
          business_unit: Business code that represents to the customer.

        Returns:
          None

        Raise:
          None
        """
        self._odc_connection = None
        self._odc_value = ""
        self.business_unit = business_unit
        self._server_url = shopfloor_url

    def __del__(self):
        class_name = self.__class__.__name__

    def connect(self, url=None):
        """Create connection.

        This function will create the HTTP connection instant for the specific
        URL. If the URL is None this function will use the URL from initial.

        Args:
          url: The server URL string. Use the initial URL if the input is None.

        Returns:
          None.

        Raise:
          None.
        """
        if url is None:
            url = self._server_url
        self._odc_connection = http.client.HTTPConnection(url, timeout=10)

    def check_connection(self, profile):
        """Check connection.

        Try to send and receive the HTTP package from the server.

        Args:
          profile: profile for check connecting ODC.

        Returns:
          None.

        Raise:
          None.
        """
        try:
            if self.request_data(
                    '/des/{}/getparameter.asp?sn=12345678912&profile'
                    '={}'.format(
                        self.business_unit, profile), 'GET'):
                return "Not found" in str(self.get_data())
            else:
                return False
        except Exception:
            return False

    def request_data(self, url, method="GET"):
        """Request data.

        Send the HTTP request data to the sever.

        Args:
          url: The server URL string.
          method: The HTTP method that will be used.

        Returns:
          True if HTTP return code is 200. False on otherwise

        Raise:
          None
        """
        try:
            if self._odc_connection is not None:
                self._odc_connection.request(method, url)
                res = self._odc_connection.getresponse()
                if res.status == 200:
                    self._odc_value = res.read()
                    return True
            return False
        except Exception:
            return False

    def get_data(self):
        """Get return data.

        Get the HTTP return data from the request_data function.

        Args:
          None

        Returns:
          None

        Raise:
          None
        """
        return self._odc_value

    def get_ticket(self, serial_number):
        """Get current ticket.

        Retrieve the current ticket number from the server.

        Args:
          serial_number: The UUT serial number.

        Returns:
          The current ticket number or error message from the server.

        Raise:
          None
        """
        self.connect(self._server_url)
        if self.request_data(
                '/des/{}/getparameter.asp?sn={}&profile=ticket'.format(
                    self.business_unit, serial_number), 'GET'):
            return self._odc_value

    def request_ticket(self, serial_number):
        """Request new ticket.

        Request new ticket for the specific serial number.

        Args:
          serial_number: The UUT serial number.

        Returns:
          The current ticket number or error message from the server.

        Raise:
          None
        """
        self.connect(self._server_url)
        if self.request_data(
                '/des/{}/getticket.asp?sn={}'.format(self.business_unit,
                                                     serial_number), 'GET'):
            return self._odc_value

    def clear_ticket(self, serial_number, ticket_number):
        """Clear current ticket.

        Clear the current ticket for the specific serial number.

        Args:
          serial_number: The UUT serial number.
          ticket_number: The ticket number string.

        Returns:
          True if 'SUCCESS' found from the return message. False on otherwise.

        Raise:
          None
        """
        self.connect(self._server_url)
        if self.request_data('/des/{}/clearticket.asp?sn={}&ticket={}'.format(
                self.business_unit, serial_number, ticket_number), 'GET'):
            if "SUCCESS" in self._odc_value.decode("utf-8"):
                return True
        return True

    ''' Get the current station id for the input serial number '''

    def get_current_station(self, serial_number):
        """Get current station.

        Retrieve the current station number for the specific serial number.

        Args:
          serial_number: The UUT serial number.

        Returns:
          The current station number or error message from the server.

        Raise:
          None
        """
        self.connect(self._server_url)
        if self.request_data(
                '/des/{}/check.asp?sn={}'.format(self.business_unit,
                                                 serial_number), 'GET'):
            return self._odc_value

    def get_profile_parameter(self, serial_number, profile):
        """Get parameter from SFC profile.

        Get the data from the SFC by profile name.

        Args:
          serial_number: The UUT serial number.
          profile: Profile name to get the data.

        Returns:
          The return value or error message from the server.

        Raise:
          None
        """
        self.connect(self._server_url)
        if self.request_data('/des/{}/getparameter.asp?profile={}&sn={}'.format(
                self.business_unit, profile, serial_number), 'GET'):
            return self._odc_value

    def get_profile_multiple_parameter(self, parameter, profile):
        """Get parameter from SFC profile with multiple parameter.

        Get the data from the SFC by profile name.

        Args:
          parameter: The URL parameter that pass into the SFC server.
          profile: Profile name to get the data.

        Returns:
          The return value or error message from the server.

        Raise:
          None
        """
        self.connect(self._server_url)
        if self.request_data('/des/{}/getparameter.asp?{}&profile={}'.format(
                self.business_unit, parameter, profile), 'GET'):
            return self._odc_value

    def process_data(self, ticket):
        """Process data.

        Process the data on the SFC by specific ticket number.

        Args:
          ticket: SFC ticket number.

        Returns:
          True if 'SUCCESS' found from the return message. False on otherwise.
        self.connect(self._server_url)
        if self.request_data(
                '/des/{}/getparameter.asp?sn={}&profile=ticket'.format(
                    self.business_unit, serial_number), 'GET'):
            return self._odc_value
        Raise:
          None
        """
        self.connect(self._server_url)
        if self.request_data(
                '/des/{}/process.asp?ticket={}&process=true'.format(
                    self.business_unit, ticket), 'GET'):
            return self._odc_value
        #     if "SUCCESS" in self._odc_value.decode("utf-8"):
        #         return True
        # return False

    def put_data(self, method, path_url, data, header, server=None):
        """Put data to SFC.

        Send the XML data format to the SFC server

        Args:
          method: HTTP method that will be used.
          path_url: The server URL path. eg. 'http://<server_ip>/<server_path>'
          data: Test data record in the XML format.
          header: The HTTP header format. eg. 'text/xml'
          server: Target server. Use the initial URL if the input is None. 

        Returns:
          True if 'SUCCESS' found from the return message. False on otherwise.

        Raise:
          None
        """
        if server is None:
            server = self._server_url
        self.connect(server)
        header = {"content-type": header}
        self._odc_connection.request(method, path_url, data, header)
        result = self._odc_connection.getresponse()
        if result.status == 200:
            self._odc_value = result.read().decode("utf-8")
            return self._odc_value
            # if "SUCCESS" in self._odc_value:
                # return self._odc_value:
        #         return True
        # return False
        # return self._odc_value:

    ''' CTH-TDC: [IUTP021-OperatorName] Get the authorization from ODC Server 
    for the input employee number and station ID '''

    def get_authorization(self, employee_number, station_id):
        """Check authorization.

        This function will check employee authorization in the specific station
        from the SFC. The test should be rejected if the employee doesn't
        have the authorization.

        Args:
          employee_number: The employee number.
          station_id: Test station id.

        Returns:
          True, if employee have the authorization in this station.
          Otherwise False.

        Raise:
          None
        """
        self.connect(self._server_url)
        if self.request_data(
                '/des/{}/getparameter.asp?module=edit_profile&profile'
                '=AUTHORIZATION&EN={}&STATION={}'.format(
                    self.business_unit, employee_number, station_id),
                'GET'):
            if "OK" in self._odc_value:
                return True
            else:
                return False


""" For developer reference and debug"""
if __name__ == '__main__':
    odc_inst = ODCServer('cthmes44', 'elm')
    odc_inst.get_profile_parameter('TOSCTH183600064', 'BOMFILE')
if __name__ == '__main__':
    odc_inst = ODCServer('cthmes44', 'elm')
    odc_inst.get_profile_parameter('TOSCTH183600064', 'BOMFILE')
