import utils

# signature: bytes -> hex
signature_bytes = [80, 11, 133, 238, 134, 75, 230, 217, 253, 62, 194, 150, 188, 157, 96, 34, 15, 105, 142, 183, 212, 151, 125, 200, 3, 163, 221, 0, 1, 37, 74, 216, 35, 138, 47, 193, 112, 21, 50, 2, 191, 18, 194, 190, 110, 117, 75, 31, 225, 247, 113, 121, 156, 106, 192, 8, 32, 123, 151, 196, 209, 154, 184, 15]
signature_hex = utils.bytes_to_hex(signature_bytes)
print("signature_hex:")
print(signature_hex)

# signature: hex -> bytes
sig_hex = "500B85EE864BE6D9FD3EC296BC9D60220F698EB7D4977DC803A3DD0001254AD8238A2FC170153202BF12C2BE6E754B1FE1F771799C6AC008207B97C4D19AB80F"
sig_bytes = utils.hex_to_bytes(sig_hex)
print("sig_bytes:")
print(sig_bytes)

# public key: bytes -> hex
pbk_bytes = [60,118,37,100,90,187,140,149,109,79,39,71,4,247,21,253,255,122,174,98,167,116,38,221,144,106,253,74,27,18,18,22]
pbk_hex = utils.bytes_to_hex(pbk_bytes)
print("pbk_hex:")
print(pbk_hex)

# public key: hex -> bytes
pk_hex= "3c7625645abb8c956d4f274704f715fdff7aae62a77426dd906afd4a1b121216"
pk_bytes = utils.hex_to_bytes(pk_hex)
print("pk_bytes:")
print(pk_bytes)

# msg: bytes -> hex
msg_bytes = [10,21,10,12,8,188,159,161,171,6,16,200,192,248,228,1,18,5,24,195,163,232,2,18,2,24,8,34,2,8,60,50,12,72,101,108,108,111,32,119,111,114,108,100,33,114,14,10,12,10,10,10,3,24,210,9,16,200,1,24,1]
msg_hex = utils.bytes_to_hex(msg_bytes)
print("msg_hex")
print(msg_hex)
