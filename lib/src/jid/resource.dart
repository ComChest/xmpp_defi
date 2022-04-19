import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';
import 'package:universal_io/io.dart' show Platform;
import 'package:bip39/bip39.dart';
//import 'package:dart_merkle_lib/dart_merkle_lib.dart';
import 'package:bs58/bs58.dart';

var rng = new Random();
/// Calling the third part of the XMPP address "device" is common in XMPP but
/// leads to confusion because one physical device can have multiple resources.
/// We use username@domain/resource and user is username@domain

class Resource{ ///AKA Device
  String _label;
  ///XEP-0384 Says Resource ID must be unique, probably to bareJID
  /// and it says it must be between  1 and 2^32-1
  late int _rID;
  DateTime _objDate = DateTime.now();
  DateTime? _dateID;
  final signatureAlgorithm = Ed25519();
  Map<String, Signature> userPublicKeys  = new Map();
  Map<SimplePublicKey, Signature> userKeySignatures = new Map();
  List<SimplePublicKey> selfPublicKeys = List.empty(growable: true);
  Map<SimplePublicKey, Signature> selfKeySignatures = new Map();

  Resource(this._label){
    _dateID = _objDate;
    _rID = max(1, rng.nextInt(pow(2,32).toInt()-1));
  }

  Resource.id(this._label, this._rID);

  String get rID {
    return _rID.toString();
  }

  String get resourceName {
    return _label + this.rID + _dateID.toString();
  }

  void set dateID(DateTime dateID){
    date
  }
  setRID(){
    _label = label;
    _dateID = dateID;
  }

  String get label{
    return _label;
  }

  getDateID(){
    return _dateID;
  }

  getStamp(){
    return _label + _dateID.toString();
  }

  verifyPubKey(PublicKey publicKey, Signature signature) {
    signatureAlgorithm.verify(
        publicKey.toString(),
        signature: signature
    )
  }

  verifyMsg(String message, Signature signature){
    signatureAlgorithm.verify(
        utf8.encode(message),
        signature: signature
    )
  }
}

class PubKeyedResource extends Resource{
  SimplePublicKey publicKey;
  ///Keys that have signed for this resource
  Map<SimplePublicKey, Signature> msgSignatures = new Map();
  //Map<int, Signature> msgSignatures = new Map();
  PubKeyedResource(_label, _dateID, this.publicKey) : super(_label, _dateID){}

  checkSignature(Signature signature){

  }

}

class ThisResource extends Resource{
  /// Our approach to signatures in XMPP: youtube.com/watch?v=oc5844dyrsc
  SimpleKeyPair _selfSignKeyPair;
  SimpleKeyPair _userSignKeyPair;
  Map<String, PubKeyedResource> selfPubKeyedResources = Map();

  var selfKeySignatures = new Map();
  ThisResource(String _label,
      DateTime _dateID,
      this._selfSignKeyPair,
      this._userSignKeyPair) : super(_label, _dateID){}

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




