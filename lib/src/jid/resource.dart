import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';

var rng = new Random();
/// Calling the third part of the XMPP address "device" is common in XMPP but
/// leads to confusion because one physical device can have multiple resources.
/// We use username@domain/resource and user is username@domain

class Resource{ ///AKA Device
  String _label;
  ///XEP-0384 Says Resource ID must be unique, probably to bareJID
  String _numID;
  final signatureAlgorithm = Ed25519();
  Map<String, Signature> userPublicKeys  = new Map();
  Map<SimplePublicKey, Signature> userKeySignatures = new Map();
  List<SimplePublicKey> selfPublicKeys = List.empty(growable: true);
  Map<SimplePublicKey, Signature> selfKeySignatures = new Map();

  Resource(this._label, this._numID){}
  setRID(String label, int numID){
    _label = label;
    _numID = numID;
  }

  getLabel(){
    return _label;
  }

  getNumID(){
    return _numID;
  }

  getRID(){
    return _label + _numID;
  }
}

class PubKeyedResource extends Resource{
  SimplePublicKey publicKey;
  ///Keys that have signed for this resource
  Map<SimplePublicKey, Signature> msgSignatures = new Map();
  Map<int, Signature> msgSignatures = new Map();
  PubKeyedResource(label, numID, this.publicKey) : super(label, numID){}

  checkSignature(Signature signature){

  }

}

class ThisResource extends Resource{
  /// Our approach to signatures in XMPP: youtube.com/watch?v=oc5844dyrsc
  SimpleKeyPair _selfSignKeyPair;
  SimpleKeyPair _userSignKeyPair;
  Map<String, PubKeyedResource> selfPubKeyedResources = Map();

  var selfKeySignatures = new Map();
  ThisResource(label,
      numID,
      this._selfSignKeyPair,
      this._userSignKeyPair) : super(label, numID){
  }

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
  return ThisResource(label,
      rng.nextInt(pow(2, 32).toInt()).toString(),
      selfSignKeyPair,
      userSignKeyPair);
}

class masterSignedResource extends ThisResource{
  SimplePublicKey masterPubKey;
  Signature masterSignature;
  ThisResource(label,
      numID,
      _selfSignKeyPair,
      _userSignKeyPair,
      this.masterPubKey,
      masterSignature)
      : super(label, numID, _selfSignKeyPair, _userSignKeyPair){
  }
}

class masterResource extends masterSignedResource{}




