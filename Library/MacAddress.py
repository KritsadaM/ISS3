"""The MAC address converter library based on macaddress python library.

A module for handling hardware identifiers like MAC addresses.

This module makes it easy to:

- 1.check if a string represents a valid MAC address, or a similar hardware
  identifier like an OUI, CDI32, CDI40, MAC/EUI48, EUI-60, EUI-64, etc,
- 2.convert between string and binary forms of MAC addresses and other
  hardware identifiers, and so on.

Note::
    !!! ``Please install the macaddress module before using this library`` !!!.

Reference:
- macaddress module (https://pypi.org/project/macaddress/)

"""
# pylint: disable=invalid-name
# pylint: disable=too-few-public-methods
# pylint: disable=unnecessary-pass
# pylint: disable=too-many-arguments
# pylint: disable=bad-staticmethod-argument

try:
    import macaddress
except ImportError as err:
    raise ImportError(
        'Importing macaddress library failed. '
        'Make sure you have macaddress installed. '
        '(Installation: pip install macaddress)'
    ) from err


__version__ = '1.0.0'


class MacAddress:
    """Base class for MAC addresses.

    can be converted the data to the MAC address.

    """

    def __init__(self):
        """Initialize the MAC address object """
        pass

    def mac_converter(self, address, hw_ident_type: str = "MAC",
                      size: int = 0, operator: str = "extended",
                      output_type: str = "str") -> str:
        """Calculate and convert the MAC address with hardware identifiers
        types.

        - Check if a string represents a valid MAC address, or a similar
          hardware identifier like an OUI, CDI32, CDI40, MAC/EUI48, EUI-60,
          EUI-64, etc,
        - Convert between string and binary forms of MAC addresses and other
          hardware identifiers, and so on.

        Example:
            >> mac_converter(address="00E0ECCC79C9", hw_ident_type="MAC",
            size=125, operator="extended", output_type="str")

        Args:
            address: The address data to parse and validate format (Support
              data type: string, integer, binary, octal, hexadecimal, and
              bytes).
            hw_ident_type: The common hardware identifier types (Support type:
              OUI, CDI32, CDI40, MAC, EUI48, EUI-60, EUI-64).
            size: The length size to calculate.
            operator: The operating (extended or dropped) use to calculate.
            output_type: The output pattern (Support pattern: str, int, bin,
              oct, hex, and bytes).

        Returns:
            The string address in the output pattern.

        Raises:
            ValueError: If the data invalid or does not match in list.
            AttributeError: The object has no attribute.
            TypeError: If the data wrong types.

        """
        standard_type = self._verify_hw_ident_type(hw_ident_type=hw_ident_type)
        mac_address = self._verify_addr_format(standard_type=standard_type,
                                               address=address)
        cal_addr = self._calculate_address_size(address=mac_address, size=size,
                                                operator=operator)
        new_mac_address = standard_type(cal_addr)
        return self._generate_output(address=new_mac_address,
                                     output_type=output_type)

    def _verify_hw_ident_type(self, hw_ident_type: str):
        """Verify common hardware identifier types.

        Check if a string represents a valid hardware identifier like an OUI,
        CDI32, CDI40, MAC/EUI48, EUI-60, EUI-64, etc,

        Args:
            hw_ident_type: The common hardware identifier types (Support type:
              OUI, CDI32, CDI40, MAC, EUI48, EUI-60, EUI-64).

        Returns:
            The common hardware identifier types object class.

        Raises:
            ValueError: If a string does not match in the common hardware
              identifier types list.

        """
        hw_ident_type = hw_ident_type.upper()
        if not hasattr(StandardTypes, hw_ident_type):
            all_types = tuple(self._get_all_class_attr_name(cls=StandardTypes))
            raise ValueError(f"Cannot find '{hw_ident_type}' type in the "
                             f"common hardware identifier types "
                             f"{all_types}")
        return getattr(StandardTypes, hw_ident_type)

    @staticmethod
    def _verify_addr_format(standard_type, address):
        """Verify address format and convert address with hardware identifier.

        Check if a string represents a valid MAC address and convert address
        with hardware identifier like an OUI, CDI32, CDI40, MAC/EUI48, EUI-60,
        EUI-64, etc,

        Args:
            standard_type: The common hardware identifier types object class.
            address: The address data to parse and validate format (Support
              data type: string, integer, binary, octal, hexadecimal, and
              bytes).

        Returns:
            The MAC address in hardware address class object.
              (Ex. MAC('01-23-45-67-89-AB'))

        Raises:
            ValueError: If the address is invalid format.
            TypeError: If the common hardware identifier wrong types.

        """
        try:
            return standard_type(address)
        except ValueError as error:
            raise ValueError(f"{error}. Check address length or address format "
                             f"{str(standard_type.formats)}") from error
        except TypeError as error:
            raise TypeError(error) from error

    def _calculate_address_size(self, address: int, size: int,
                                operator: str) -> int:
        """Extended or dropped the address with length size.

        Args:
            address: The address in type integer to calculate.
            size: The length size to calculate.
            operator: The operating (extended or dropped) use to calculate.

        Returns:
            The new address in type integer after calculate.

        Raises:
            ValueError: If the operator does not match in the operators list.

        """
        operator = operator.lower()
        if not hasattr(Operators, operator):
            all_types = tuple(self._get_all_class_attr_name(cls=Operators))
            raise ValueError(f"Cannot find '{operator}' in the "
                             f"operators list {all_types}")
        if operator == Operators.extended:
            return int(address) + size
        if operator == Operators.dropped:
            return int(address) - size

        return int(address) + size

    def _generate_output(self, address, output_type: str):
        """Convert the output to other pattern.

        Note:
            All types will return to the pattern your select but the type of
            the data are string type.

        Args:
            address: The address object class.
            output_type: The output pattern (Support pattern: str, int, bin,
              oct, hex, and bytes).

        Returns:
            The string address in the output pattern.

        Raises:
            ValueError: If the output pattern does not match in the output
              type list.

        """
        output_type = output_type.lower()
        all_types = tuple(self._get_all_class_attr_val(cls=OutputPattern))
        if output_type not in all_types:
            raise ValueError(f"Cannot find '{output_type}' in the "
                             f"output type list {all_types}")

        if output_type == OutputPattern.pattern_int:
            # Ex. 145862325757409
            return str(int(address))
        if output_type == OutputPattern.pattern_bin:
            # Ex. 0b100001001010100100111000000111001110010111100001
            return bin(int(address))
        if output_type == OutputPattern.pattern_oct:
            # Ex. 0o4112447007162741
            return oct(int(address))
        if output_type == OutputPattern.pattern_hex:
            # Ex. 0x84a9381ce5e1
            return hex(int(address))
        if output_type == OutputPattern.pattern_bytes:
            # Ex. b'\x00\x84\xa98\x1c\xe5\xe1'
            return str(bytes(address))  # unsigned

        # Ex. 01-02-03-0A-0B-0C
        return str(address)

    @staticmethod
    def _get_all_class_attr_name(cls) -> list:
        """Get all attribute keys from class object.

        Args:
            cls: The object class that needs to get the attribute.

        Returns:
            The list of attribute keys in the object class.

        Raises:
            AttributeError: The object has no attribute.

        """
        return [attr for attr in dir(cls) if not attr.startswith('_')]

    def _get_all_class_attr_val(self, cls) -> list:
        """Get all attribute values from class object.

        Args:
            cls: The object class that needs to get the attribute.

        Returns:
            The list of attribute values in the object class.

        Raises:
            AttributeError: The object has no attribute.

        """
        attr_name = self._get_all_class_attr_name(cls=cls)
        return [getattr(cls, attr) for attr in attr_name]

    def _get_class_attr(self, cls) -> dict:
        """Get the attribute keys and attribute value from class object.

        Args:
            cls: The object class that needs to get the attribute.

        Returns:
            The dictionary of attribute in the object class.

        Raises:
            AttributeError: The object has no attribute.

        """
        attr_dict = {}
        attr_name = self._get_all_class_attr_name(cls=cls)
        for attr in attr_name:
            attr_dict[attr] = getattr(cls, attr)
        return attr_dict


class StandardTypes:
    """Classes are provided for common hardware identifier types."""
    OUI = macaddress.OUI
    CDI32 = macaddress.CDI32
    CDI40 = macaddress.CDI40
    MAC = macaddress.MAC
    EUI48 = macaddress.EUI48
    EUI60 = macaddress.EUI60
    EUI64 = macaddress.EUI64


class Operators:
    """Classes are provided for operating types."""
    extended = "extended"
    dropped = "dropped"


class OutputPattern:
    """Classes are provided for output pattern.

    All types will return to the pattern your select but the type of the data
    are string type.
    """
    pattern_str = "str"  # 01-02-03-0A-0B-0C
    pattern_int = "int"  # 145862325757409
    pattern_bin = "bin"  # 0b100001001010100100111000000111001110010111100001
    pattern_hex = "hex"  # 0x84a9381ce5e1
    pattern_oct = "oct"  # 0o4112447007162741
    pattern_bytes = "bytes"  # b'\x00\x84\xa98\x1c\xe5\xe1'
