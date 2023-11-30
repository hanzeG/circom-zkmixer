import binascii

def hex_to_bytes(hex_string):
    byte_array = binascii.unhexlify(hex_string)
    return list(byte_array)

def bytes_to_hex(byte_array):
    hex_string = ''.join(['{:02x}'.format(byte) for byte in byte_array])
    return hex_string

# msg_hex_result
# msg_byte_array = [10,21,10,12,8,236,216,155,171,6,16,136,199,181,198,2,18,5,24,195,163,232,2,18,2,24,8,34,2,8,60,50,12,72,101,108,108,111,32,119,111,114,108,100,33,114,0]
msg_byte_array = [10,20,10,11,8,242,150,161,171,6,16,168,216,191,102,18,5,24,195,163,232,2,18,2,24,8,34,2,8,60,50,12,72,101,108,108,111,32,119,111,114,108,100,33,114,14,10,12,10,10,10,3,24,210,9,16,200,1,24,1]
msg_hex_result = bytes_to_hex(msg_byte_array)
print("msg_hex_result:")
print(msg_hex_result)

# public key
pbk = "3C7625645ABB8C956D4F274704F715FDFF7AAE62A77426DD906AFD4A1B121216"
pbk_bytes = hex_to_bytes(pbk)
print("pbk_bytes")
print(pbk_bytes)

# hex2bytes
hex_string = "17BAE27EC7208285D51CD6D28FF9FC851353D7C72D9966CF013337177F78F5F8C42B1B95ACDCA274B357E547E0EF0541338BCED493E847436014EB78760F780C"
byte_result = hex_to_bytes(hex_string)

print("byte_result:")
print(byte_result)