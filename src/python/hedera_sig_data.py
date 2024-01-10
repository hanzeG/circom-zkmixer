import json

def reverse_bytes_get_A(input_data):
    if isinstance(input_data, int):
        input_data = input_data.to_bytes((input_data.bit_length() + 7) // 8, byteorder='big')
    elif isinstance(input_data, str):
        if input_data.startswith("0x"):
            input_data = bytes.fromhex(input_data[2:])
        else:
            input_data = input_data.encode('utf-8')
    elif not isinstance(input_data, bytes):
        raise ValueError("Input data must be int, hex string, bits string, or bytes")

    reversed_data = input_data[::-1]
    return reversed_data


def hex_string_to_integer_get_S(hex_string):

    bytes_data = bytes.fromhex(hex_string)

    reversed_bytes_data = bytes_data[::-1]

    bits_string = ''.join(format(byte, '08b') for byte in reversed_bytes_data)

    bits_string_256 = bits_string[1:256]

    result = int(bits_string_256, 2)

    return result


def hex_string_to_integer_get_R8(hex_string):

    bytes_data = bytes.fromhex(hex_string)

    reversed_bytes_data = bytes_data[::-1]

    bits_string = ''.join(format(byte, '08b') for byte in reversed_bytes_data)

    bits_string_256 = bits_string[-256:]

    result = int(bits_string_256, 2)

    return result


def buffer_to_bits(buffer):
    # Implement buffer2bits function in Python
    return ''.join(format(byte, '08b') for byte in buffer)

def pad(bits, length):
    bits_str = ''.join(map(str, bits))
    return bits_str + '0' * (length - len(bits_str))

def chunk_big_int(n, chunk_size):
    # Implement chunkBigInt function in Python
    chunks = []
    while n > 0:
        chunk = n % chunk_size
        chunks.append(chunk)
        n //= chunk_size
    return chunks

p = 2**255 - 19


def modp_inv(x):
    return pow(x, p-2, p)


modp_sqrt_m1 = pow(2, (p-1) // 4, p)

d = -121665 * modp_inv(121666) % p


def point_decompress(s):
    if len(s) != 32:
        raise Exception("Invalid input length for decompression")

    y = int.from_bytes(s)
    sign = y >> 255
    y &= (1 << 255) - 1
    x = recover_x(y, sign)

    if x is None:
        return None
    else:
        return (x, y, 1, x*y % p)

# sign, or return None on failure


def recover_x(y, sign):
    if y >= p:
        return None
    x2 = (y*y-1) * modp_inv(d*y*y+1)
    if x2 == 0:
        if sign:
            return None
        else:
            return 0

    x = pow(x2, (p+3) // 8, p)
    if (x*x - x2) % p != 0:
        x = x * modp_sqrt_m1 % p
    if (x*x - x2) % p != 0:
        return None

    if (x & 1) != sign:
        x = p - x
    return x


def main():
    # msg
    print("------------------------------------------------")
    msg_hex = "0x0a150a0c08bc9fa1ab0610c8c0f8e401120518c3a3e802120218082202083c320c48656c6c6f20776f726c6421720e0a0c0a0a0a0318d20910c8011801"
    
    # hex -> bigInt
    msg_by = reverse_bytes_get_A(msg_hex)
    msg = int.from_bytes(msg_by, byteorder='big')
    print("msg:", msg)
    # bigInt -> bits
    msg_bits = bin(msg)[2:]
    msg_bits_len = len(msg_bits)
    print("msg_bits_len:", msg_bits_len)
    # needed_padding = (8 - (msg_bits_len % 8))
    # print("needed_padding:", needed_padding)

    public_key_hex = "0x3c7625645abb8c956d4f274704f715fdff7aae62a77426dd906afd4a1b121216"

    # test 
    # public_key_hex = 0xfc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025 # test 
    # test 

    signature_hex = "500b85ee864be6d9fd3ec296bc9d60220f698eb7d4977dc803a3dd0001254ad8238a2fc170153202bf12c2be6e754b1fe1f771799c6ac008207b97c4d19ab80f"

    # test 
    # signature_hex = "6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a" # test 
    # test 

    # R8
    print("------------------------------------------------")

    # test
    # R8_int = 78142972218048021222160463610080218564159109753358461787358041591257467621730     # test
    # test

    R8 = hex_string_to_integer_get_R8(signature_hex)
    print("R8: ", R8)
    # S
    # print("------------------------------------------------")
    # S_bits = sig_bits[-256:-1]
    # len_S = len(S_bits)
    # print("S_bits:", S_bits)
    # print("S_lens:", len_S)
    # bits -> bigInt
    S = hex_string_to_integer_get_S(signature_hex)
    print("S:", S)

    # A
    print("------------------------------------------------")

    # test
    # A_int = 16962727616734173323702303146057009569815335830970791807500022961899349823996     # test
    # test

    A_by = reverse_bytes_get_A(public_key_hex)
    A = int.from_bytes(A_by, byteorder='big')
    print("A: ", A)

    # Point R
    print("------------------------------------------------")
    # bigInt -> bytes
    R8_bytes = R8.to_bytes(
        (R8.bit_length() + 7) // 8)
    lens_R8_bytes = len(R8_bytes)
    print("R8_bytes: ", R8_bytes)
    print("R8_bytes lens: ", lens_R8_bytes)
    point_R = point_decompress(R8_bytes)
    if point_R is None:
        print("Decompression Point R failed.")
    else:
        print("Decompressed Point R:", point_R)

    # Point A
    print("------------------------------------------------")
    # bigInt -> bytes
    A_bytes = A.to_bytes(
        (A.bit_length() + 7) // 8)
    lens_A_bytes = len(A_bytes)
    print("A_bytes: ", A_bytes)
    print("A_bytes lens: ", lens_A_bytes)
    point_A = point_decompress(A_bytes)
    if point_A is None:
        print("Decompression Point A failed.")
    else:
        print("Decompressed Point A:", point_A)

    # Create a dictionary to store the results
    result_dict = {
        "PointA": point_A,
        "PointR": point_R,
        "A": A,
        "msg": msg,
        "R8": R8,
        "S": S,}

    # Output the results to a JSON file
    with open("/Users/guohanze/Documents/zkp-solutions/zkp/src/python/hedera_test_input.json", "w") as json_file:
        json.dump(result_dict, json_file)


if __name__ == "__main__":
    main()