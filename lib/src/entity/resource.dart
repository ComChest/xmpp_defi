import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';
import 'package:universal_io/io.dart' show Platform;
import 'package:bip39/bip39.dart';
// To add when :
// import 'package:dart_merkle_lib/dart_merkle_lib.dart';
import 'package:bs58/bs58.dart';

var rng = new Random();
/// Calling the third part of the XMPP address "device" is common in XMPP but
/// leads to confusion because one physical device can have multiple resources.
/// We use username@domain/resource and user is username@domain

class Resource{ ///AKA Device
  /// XEP-0384 Says Resource ID must be unique (probably to bareJID)
  /// and it says it must be between 1 and 2^32-1
  String _label;
  get signatureAlgorithm {return Ed25519();}
  get baseHash {return Sha512();}
  final hMAC = Hmac.sha512();

  Platform? resourcePlatform;
  Map<String, Signature> userPublicKeys  = new Map();
  Map<SimplePublicKey, Signature> userKeySignatures = new Map();
  List<SimplePublicKey> selfPublicKeys = List.empty(growable: true);
  Map<SimplePublicKey, Signature> selfKeySignatures = new Map();

  Resource(this._label);

  String get rID {
    return _rID.toString();
  }

  String get label{
    return _label;
  }



  void set dateID(DateTime dateID){
    _dateID = dateID;
  }

  DateTime get dateID{
    return _dateID;
  }

  String get label {
    return _label;
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

class PubKeyedResource extends Resource{
  /// Has pubkey(s) (and rid) for OMEMO
  late int _rID;
  SimplePublicKey _userPublicKey;  ///User Signing Key
  SimplePublicKey _selfPublicKey;  ///Self Signing Key
  String? ref;
  ///Keys that have signed for this resource
  Map<SimplePublicKey, Signature> msgSignatures = new Map();
  //Map<int, Signature> msgSignatures = new Map();
  PubKeyedResource(super._label, this._userPublicKey,  this._selfPublicKey, this._rID);

  SimplePublicKey userPublicKey
  checkSignature(Signature signature){

  }
}

class ThisResource extends PubKeyedResource{
  DateTime _objDate = DateTime.now();
  late DateTime _dateID;
  // Will add branch date for XMSS
  /// Our approach to signatures in XMPP: youtube.com/watch?v=oc5844dyrsc
  /// We also support signing the address (hash of pubkey) or
  /// reference (HMAC of pub key and XMPP address/bareJID) and
  /// will support XMSS authentication https://datatracker.ietf.org/doc/html/rfc8391
  SimpleKeyPair _selfSignKeyPair;
  SimpleKeyPair _userSignKeyPair;
  Map<String, PubKeyedResource> selfPubKeyedResources = Map();

  var selfKeySignatures = new Map();
  ThisResource(String _label,
      DateTime _dateID,
      this._selfSignKeyPair,
      this._userSignKeyPair, {super._rID});

  String get label {
    return rID.toString();
  }

  // should overide
  getPubSelfKey(){
    return _selfSignKeyPair.extractPublicKey();
  }

  getPubUserKey(){
    return _userSignKeyPair.extractPublicKey();
  }
  //Will need to add hash of private key to access private key

  signSelf(self){
    return signatureAlgorithm.sign([self], keyPair: _selfSignKeyPair);
  }

  signUser(user){
    return signatureAlgorithm.sign([user], keyPair: _userSignKeyPair);
  }
}

/// This is for when the user wants to name part of their label
makeThisResource({label='ComChest'}) async {
  final signatureAlgorithm = Ed25519();
  final selfSignKeyPair = signatureAlgorithm.newKeyPair();
  final userSignKeyPair = signatureAlgorithm.newKeyPair();
  ///XEP-0384 Says Resource ID must be *unique*, probably means to bareJID
  String final_label = label;
  if (label == 'ComChest'){
    final_label = label + Platform.operatingSystem;
  }

  return ThisResource(final_label,
      DateTime.now(),
      await selfSignKeyPair,
      await userSignKeyPair);
}

class MasterSignedResource extends ThisResource{
  SimplePublicKey masterPubKey;
  Signature masterSignature;
  MasterSignedResource(_label,
      _dateID,
      _selfSignKeyPair,
      _userSignKeyPair,
      this.masterPubKey,
      this.masterSignature)
      : super(_label, _dateID, _selfSignKeyPair, _userSignKeyPair){
  }
}

///Private Key should be encrypted with Argon2ID of a password
//class masterResource extends MasterSignedResource{}




