# Example Credentials ----------------------------------------------------------
import xrpl
from xrpl.wallet import Wallet
from xrpl.constants import CryptoAlgorithm
from xrpl.asyncio.transaction import main as m
from xrpl.core import keypairs
import json

def gen_txn():
    # seed = keypairs.generate_seed()
    # print('Seed:')
    # print(seed)
    # pub_key = keypairs.derive_keypair(seed)
    # print("Key Pair:")
    # print(pub_key)
    seed = "sEdSYHYvjtJ9iAC4cHpCEq9fu463LKS"
    print("rand_seed", seed)
    test_wallet = Wallet.from_seed(
        seed = seed, algorithm=CryptoAlgorithm.ED25519)
    print("address:", test_wallet.address)

    # Prepare transaction ----------------------------------------------------------
    my_payment = xrpl.models.transactions.Payment(
        account = test_wallet.address,
        amount=xrpl.utils.xrp_to_drops(222),
        destination="rLC267LJedUPzvju3Lowsk9ZPSFnnMWgif",
    )
    print("Payment object:", my_payment)
    signed_tx = xrpl.transaction.sign(my_payment, test_wallet, False)
    max_ledger = signed_tx.last_ledger_sequence
    tx_id = signed_tx.get_hash()
    print("------------------------------------------------")
    print("Signed transaction:", signed_tx)
    print("------------------------------------------------")
    print("Identifying hash:", tx_id)

    sig_hex = "099C0305791C8074289BDA39DB2095FB8F9EDF2DDBF37E578BF95E8FA6FDA0CDAB351AC636C34F8956D44DE6017E53DCA32E7DDCEF492BB81157D8B366497706"
    sig_bytes = bytes.fromhex(sig_hex)
    pubkey_hex = "ED4F782E6B8E792D4AA2795E32508DBF5502CFDEABD1BE6DC0A4CFCB66EC73FCAE"
    transaction_json = m._prepare_transaction(my_payment, test_wallet)
    serialized_for_signing = m.encode_for_signing(transaction_json)
    serialized_bytes = bytes.fromhex(serialized_for_signing)
    result = xrpl.core.keypairs.is_valid_message(serialized_bytes, sig_bytes, pubkey_hex)
    print("is valid:", result)
    print("------------------------------------------------")
    print("serialized_bytes", serialized_bytes)
    print("Len of serialized_bytes: " ,len(serialized_bytes))
    print("------------------------------------------------")
    print("serialized_for_signing", serialized_for_signing)
    pubkey_hex = "0x4F782E6B8E792D4AA2795E32508DBF5502CFDEABD1BE6DC0A4CFCB66EC73FCAE"
    unsigned_msg = "0x53545800120000220000000061400000000D3B73807321ED4F782E6B8E792D4AA2795E32508DBF5502CFDEABD1BE6DC0A4CFCB66EC73FCAE8114375DC5E145E84FD614195684F086BAC7B45655468314D7B653702876ED1D77AA20F5B9CF9A9DE8BBDCDA"
    return(pubkey_hex, unsigned_msg, sig_hex)


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

    data = gen_txn()

    # msg
    print("------------------------------------------------")
    msg_hex = data[1]
    
    # test 
    # msg_hex = "0xaf82" # test
    # test 
    
    
    # hex -> bigInt
    msg_by = reverse_bytes_get_A(msg_hex)
    msg = int.from_bytes(msg_by, byteorder='big')
    print("msg:", msg)
    # bigInt -> bits
    # msg_bits = bin(msg)[2:]
    # msg_bits_len = len(msg_bits)
    # print("msg_bits_len:", msg_bits_len)
    # needed_padding = (8 - (msg_bits_len % 8))
    # print("needed_padding:", needed_padding)

    public_key_hex = data[0]

    # test 
    # public_key_hex = 0xfc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025 # test 
    # test 

    signature_hex = data[2]

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
    with open("/Users/guohanze/Documents/zkp-solutions/zkp/src/python/test_input.json", "w") as json_file:
        json.dump(result_dict, json_file)


if __name__ == "__main__":
    main()