import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'package:universal_io/io.dart' show Platform;

var rng = new Random();
/// Calling the third part of the XMPP address "device" is common in XMPP but
/// leads to confusion because one physical device can have multiple resources.
/// We use username@domain/resource and user is username@domain

class Resource{ ///AKA Device
  String _label;
  ///XEP-0384 Says Resource ID must be unique, probably to bareJID
  DateTime _dateID;
  final signatureAlgorithm = Ed25519();
  Map<String, Signature> userPublicKeys  = new Map();
  Map<SimplePublicKey, Signature> userKeySignatures = new Map();
  List<SimplePublicKey> selfPublicKeys = List.empty(growable: true);
  Map<SimplePublicKey, Signature> selfKeySignatures = new Map();

  Resource(this._label, this._dateID){}
  setRID(String label, DateTime dateID){
    _label = label;
    _dateID = dateID;
  }

  getLabel(){
    return _label;
  }

  getDateID(){
    return _dateID;
  }

  getRID(){
    return _label + _dateID.toString();
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

//class masterResource extends MasterSignedResource{}




