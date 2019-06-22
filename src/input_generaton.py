# %%
from zokrates.gadgets.pedersenHasher import PedersenHasher

from os import urandom

##TODOS
# create pedersen hasher with fixed bitwith (for input)
# add compresseion to pedersen hasher? .. probably NOT
# rebuild sha256 example using the new conditional multiplexer
# make context a parameter

#%%
import json
import bitstring

#%%
payload = {}
with open("out/proof_data.json") as json_file:
    payload = json.load(json_file)


#%%
def hex_to_args(hex_str):
    bytes_object = bytes.fromhex(hex_str)
    bin_str = bitstring.BitArray(bytes_object).bin
    return list(bin_str)


#  %%
#%%

# import bitstring
# import hashlib
# hashlib.sha256(int.to_bytes(0x28481a380d2f267cede6d53161ac16c813b172b553c1fd5a15811919cd50e25c, 32, "big")).digest().hex()
# #'bcbb8f97980d5691e1d668f7e7614c052ce6bb25fed3a7f9d10ce94bcb82916a'


class ZoKratesArg(object):
    def __init__(self, name, is_public, size, assignment=None):
        self.name = name
        self.is_public = is_public
        self.size = size
        self.assignment = assignment


class ZoKratesMainArgs(object):
    def __init__(self):
        self.args = []

    def push(self, arg):
        self.args.append(arg)

    def get_bitstr(self):
        args = self.args
        if not args:
            raise ValueError("No arguments defined")

        bitstr_array = []
        for arg in args:
            if not arg.assignment:
                raise ValueError(
                    "Argmuement {} can not be lazy evaluated".format(arg.name)
                )
            bitstr = arg.assignment() if callable(arg.assignment) else arg.assignment
            if len(bitstr) != arg.size:
                raise ValueError(
                    "Arg: {}. Assignment does not match definition. Found {}, expected {}".format(
                        arg.name, len(bitstr), arg.size
                    )
                )
            bitstr_array.append(bitstr)

        tmp = [" ".join(e) for e in bitstr_array]
        bitstr_concat = " ".join(tmp)
        self.bitstr = bitstr_concat
        return bitstr_concat

    def write_witness(self, path):
        if not self.bitstr:
            _ = self.get_bitstr()

        with open(path, "w+") as f:
            f.write(self.bitstr)

    def get_signature(self):

        args = self.args
        if not args:
            raise ValueError("No arguments defined")

        sig_array = []
        for arg in args:
            if arg.size == 1:
                sig = "field {}".format(arg.name)
            else:
                sig = "field[{}] {}".format(arg.size, arg.name)
            if not arg.is_public:
                sig = "private" + sig
            sig_array.append(sig)

        return ", ".join(sig_array)

    def get_arg_names(self):
        for arg in self.args:
            print(arg.name)


#%%
nft = ZoKratesMainArgs()

# nft.push(ZoKratesArg("creditRatingRootHash", True, 256, hex_to_args(payload['public']['credit_rating_roothash'])))
roothash_hex = payload["public"]["credit_rating_roothash"]
nft.push(
    ZoKratesArg(
        "creditRatingRootHashField",
        True,
        2,
        [str(int(roothash_hex[0:32], 16)), str(int(roothash_hex[32:64], 16))],
    )
)

# %%
# nft.push(ZoKratesArg("buyerRating", True, 8, hex_to_args(payload['public']['rating'])))
rating_hex = payload["public"]["rating"]
nft.push(ZoKratesArg("buyerRatingField", True, 1, [str(int(rating_hex, 16))]))

buyerID = payload["private"]["buyer_rating_proof"]["value"][0:40]
nft.push(ZoKratesArg("buyerID", False, 160, hex_to_args(buyerID)))

buyerPubKey = payload["private"]["buyer_rating_proof"]["value"][40:104]
nft.push(ZoKratesArg("buyerPubkey", False, 256, hex_to_args(buyerPubKey)))

directions = payload["private"]["buyer_rating_proof"]["right"]
directions = ["1" if d == True else "0" for d in directions]
nft.push(ZoKratesArg("directionCreditRatingTree", False, 2, "".join(directions)))

hashes = payload["private"]["buyer_rating_proof"]["hashes"]
for i, hash in enumerate(hashes):
    nft.push(
        ZoKratesArg("creditRatingTreeDigest{}".format(i), False, 256, hex_to_args(hash))
    )

#%%

nft_amount = payload["public"]["nft_amount"]
nft.push(ZoKratesArg("nftAmount", True, 1, [str(int(nft_amount, 10))]))

# nft.push(ZoKratesArg("documentRootHash", True, 256, hex_to_args(payload['public']['document_roothash'])))
roothash_hex = payload["public"]["document_roothash"]
nft.push(
    ZoKratesArg(
        "documentRootHashField",
        True,
        2,
        [str(int(roothash_hex[0:32], 16)), str(int(roothash_hex[32:64], 16))],
    )
)
nft.push(
    ZoKratesArg(
        "invoiceAmountValue",
        False,
        256,
        hex_to_args(payload["private"]["document_invoice_amount_proof"]["value"]),
    )
)
nft.push(
    ZoKratesArg(
        "invoiceAmountProperty",
        False,
        64,
        hex_to_args(payload["private"]["document_invoice_amount_proof"]["property"]),
    )
)
nft.push(
    ZoKratesArg(
        "invoiceAmountSalt",
        False,
        256,
        hex_to_args(payload["private"]["document_invoice_amount_proof"]["salt"]),
    )
)

directions = payload["private"]["document_invoice_amount_proof"]["right"]
directions = ["1" if d == True else "0" for d in directions]
nft.push(ZoKratesArg("invoiceAmountTreeDirection", False, 8, "".join(directions)))


hashes = payload["private"]["document_invoice_amount_proof"]["hashes"]
for i, hash in enumerate(hashes):
    nft.push(
        ZoKratesArg(
            "invoiceAmountTreeDigests{}".format(i), False, 256, hex_to_args(hash)
        )
    )


#%%
nft.push(
    ZoKratesArg(
        "invoiceBuyerValue",
        False,
        160,
        hex_to_args(payload["private"]["document_invoice_buyer_proof"]["value"]),
    )
)
nft.push(
    ZoKratesArg(
        "invoiceBuyerProperty",
        False,
        64,
        hex_to_args(payload["private"]["document_invoice_buyer_proof"]["property"]),
    )
)
nft.push(
    ZoKratesArg(
        "invoiceBuyerSalt",
        False,
        256,
        hex_to_args(payload["private"]["document_invoice_buyer_proof"]["salt"]),
    )
)

directions = payload["private"]["document_invoice_buyer_proof"]["right"]
directions = ["1" if d == True else "0" for d in directions]
nft.push(ZoKratesArg("invoiceBuyerTreeDirection", False, 8, "".join(directions)))


hashes = payload["private"]["document_invoice_buyer_proof"]["hashes"]
for i, hash in enumerate(hashes):
    nft.push(
        ZoKratesArg(
            "invoiceBuyerTreeDigests{}".format(i), False, 256, hex_to_args(hash)
        )
    )
#%%

from zokrates.field import FQ
from zokrates.babyjubjub import Point
from zokrates.eddsa import PrivateKey, PublicKey

sig_hex = payload["private"]["buyer_signature"]
r_hex = sig_hex[0:64]
s_hex = sig_hex[64:128]
msgForSign = (
    payload["public"]["document_roothash"]
    + "00" # Need to append signature transition, might pass it as parameter in JSON
)
msgForNext = (
  payload["public"]["document_roothash"]
  + "0000000000000000000000000000000000000000000000000000000000000000"
)
# msg = msg.encode("ascii")
msgForSign = bytes.fromhex(msgForSign)
msgForNext = bytes.fromhex(msgForNext)
pk_hex = payload["private"]["buyer_pubkey"]

pk = PublicKey(Point.decompress(bytes.fromhex(pk_hex)))
r = Point.decompress(bytes.fromhex(r_hex))
s = FQ(int(s_hex, 16))

success = pk.verify((r, s), msgForSign)
assert success == True, "Signature not valid"
# + BUYER1_KEY='20966a1b510fdcf0caf6ec3cd1f238a5ac23c001dbee68b311276ccf95400df5 1c79b3f2bd10ad0528afb64ee68188665a1e77c7a320ce15e5c4ea4656b5ed0a'
# // field isVerified = verifyEddsa(R, S, A, M, padding, context)
nft.push(ZoKratesArg("SignatureR", False, 2, [str(r.x.n), str(r.y.n)]))
nft.push(ZoKratesArg("SignatureS", False, 1, [str(s.n)]))
nft.push(ZoKratesArg("BuyerPubKey", False, 2, [str(pk.p.x.n), str(pk.p.y.n)]))

#%%

sig_R = r
sig_S = s

args = [sig_R.x, sig_R.y, sig_S, pk.p.x.n, pk.p.y.n]
args = " ".join(map(str, args))

M0 = msgForNext.hex()[:64]
M1 = msgForNext.hex()[64:]
b0 = bitstring.BitArray(int(M0, 16).to_bytes(32, "big")).bin
# b1 = bitstring.BitArray(int(M1, 16).to_bytes(32, "big")).bin
args = args + " " + " ".join(b0)
#%%
print("signatue")
print(nft.get_signature())

#%%
print("inputs")
print(nft.get_bitstr())

path = "out/nft_witness.txt"
with open(path, "w+") as f:
    f.write(nft.get_bitstr())

# #%%
# print("arg names")
# nft.get_arg_names()
# #%%
# print("public input variables")
# for n in nft.args:
#     if n.is_public:
#         print(n.name)

# #%%
# print("public assignments ")
# for n in nft.args:
#     if n.is_public:
#         print(n.assignment)
