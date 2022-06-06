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
  DateTime _objDate = DateTime.now();
  /// XEP-0384 Says Resource ID must be unique (probably to bareJID)
  /// and it says it must be between 1 and 2^32-1
  late String _label;
  get signatureAlgorithm {return Ed25519();}
  get baseHash {return Sha512();}
  final hMAC = Hmac.sha512();

  Platform? resourcePlatform;
  Map<String, Signature> userPublicKeys  = new Map();
  Map<SimplePublicKey, Signature> userKeySignatures = new Map();
  List<SimplePublicKey> selfPublicKeys = List.empty(growable: true);
  Map<SimplePublicKey, Signature> selfKeySignatures = new Map();

  Resource(this._label){}

  String get label{
    return _label;
  }

  // Must set new signature algorithm
  verifyMsg(List <int> message, Signature signature){
    return this.signatureAlgorithm.verify(
        message,
        signature: signature
    );
  }

}

class PubKeyedResource extends Resource{
  /// Has pubkey(s) (and rid) for OMEMO
  late int _rID;
  late Future<SimplePublicKey> _userPublicKey;  ///User Signing Key
  late Future<SimplePublicKey> _selfPublicKey;  ///Self Signing Key
  ///Keys that have signed for this resource
  Map<SimplePublicKey, Signature> msgSignatures = new Map();
  //Map<int, Signature> msgSignatures = new Map();
  PubKeyedResource(super._label, this._userPublicKey,  this._selfPublicKey, this._rID);
  checkSignature(Signature signature){

  }
}

class ThisResource extends PubKeyedResource{
  DateTime madeDate;
  // Will add branch date for XMSS
  /// Our approach to signatures in XMPP: youtube.com/watch?v=oc5844dyrsc
  /// We also support signing the address (hash of pubkey) or
  /// reference (HMAC of pub key and XMPP address/bareJID) and
  /// will support XMSS authentication https://datatracker.ietf.org/doc/html/rfc8391
  SimpleKeyPair _userSignKeyPair;
  SimpleKeyPair _selfSignKeyPair;
  Map<String, PubKeyedResource> selfPubKeyedResources = Map();

  var selfKeySignatures = new Map();
  ThisResource(
      _rID,
      this.madeDate,
      this._userSignKeyPair,
      this._selfSignKeyPair) :
        super(_rID.toString(),
          _userSignKeyPair.extractPublicKey(),
          _userSignKeyPair.extractPublicKey(),
          _rID);

  @override
  String get label {
    return _rID.toString();
  }

  String get _label {
    return _rID.toString();
  }

  /*
  @override
  Future<SimplePublicKey> get _userPublicKey {
    return _userSignKeyPair.extractPublicKey();
  }  ///User Signing Key

  @override
  Future<SimplePublicKey> get _selfPublicKey {
    return _selfSignKeyPair.extractPublicKey();
  }  ///Self Signing Key
  */
  //Will need to add hash of private key to access private key

  signUser(user){
    return signatureAlgorithm.sign([user], keyPair: _userSignKeyPair);
  }

  signSelf(self){
    return signatureAlgorithm.sign([self], keyPair: _selfSignKeyPair);
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




