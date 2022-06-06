import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';
// import 'package:dart_merkle_lib/dart_merkle_lib.dart'; Package cannot sign yet


// Only One Pub Key
// User and Self Signing Keys - Can allow downgrade attack if selfSigning or userSigning Key is compromised
// Master plus Self and User Signing Keys
// Successor plus Master Signing Keys
// SelfSigningKeys

SignatureAlgorithm defaultResourceAlgorithm = Ed25519();
SignatureAlgorithm defaultMasterAlgorithm = Ed25519(); //2030 Ed448()
// SignatureAlgorithm defaultSuccesorSigningAlgorithm = [XMSS()];

// Only one key, which essentially acts as Master, User, Signer and Self Signer
class PubKeySet {
  get signatureAlgorithm {return defaultResourceAlgorithm;}
  get baseHash {return Sha256();}
  final hMAC = Hmac.sha256();
  SimplePublicKey _publicKey;
  SimplePublicKey get publicKey {
    return _publicKey;
  }

  PubKeySet(this._publicKey);

  String get keyReference{
    return baseHash(defaultResourceAlgorithm);
  }

  verifyMsg(List <int> message, Signature signature){
    return signatureAlgorithm.verify(
        message,
        signature: signature
    );
  }

  verifyPubKey(PublicKey pubKey, Signature signature) {
    return verifyMsg(utf8.encode(pubKey.toString()), signature);
  }

  verifyKeyHash(PublicKey pubKey, Signature signature) async {
    final digest = await baseHash.hash(utf8.encode(pubKey.toString()));
    return verifyMsg(digest.bytes.sublist(0, 31), signature);
  }

  verifyKeyAddress(String domain, int pubKey, Signature signature) async {
    final mac = await hMAC.calculateMac(
        utf8.encode(domain),
        secretKey: SecretKey([pubKey])
    );
    return verifyMsg(mac.bytes.sublist(0, 31), signature);
  }

  verifyKeyReference(String bareSID, int pubKey, Signature signature) async {
    final mac = await hMAC.calculateMac(
        utf8.encode(bareSID),
        secretKey: SecretKey([pubKey])
    );
    return verifyMsg(mac.bytes.sublist(0, 31), signature);
  }
}

// User Signing Key is assumed to be the generic Public key of this set
// This can happen if user and self signing keys are referenced without master
class DualPubKeySet {

}

//Master Key is assumed to be the generic Public key of this set
class MasterPubKeySet {

}

//Succesor Signing Key is assumed to be the generic Public key of this set
class SuccessorPubKeySet {

}