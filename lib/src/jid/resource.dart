import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';

var rng = new Random();
/// Calling the third part of the XMPP address "device" is common in XMPP but
/// leads to confusion because one physical device can have multiple resources.

class Resource{ ///AKA Device
  String _label;

  ///XEP-0384 Says Resource ID must be unique, probably to bareJID
  String _numID;
  List<String> _selfFIDs = [];
  List<String> _selfSIDs = [];
  var userPublicKeys = new Map();
  var userKeySignatures = new Map();
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
  Map<List<int>, Signature> msgSignatures = new Map();
  PubKeyedResource(label, numID, this.publicKey) : super(label, numID){}
}

class ThisResource extends Resource{
  /// Our approach to signatures in XMPP: youtube.com/watch?v=oc5844dyrsc
  SimpleKeyPair _selfSignKeyPair;
  SimpleKeyPair _userSignKeyPair;
  selfPublicKeys = new Map<String, KeyedResource>();
  var selfKeySignatures = new Map();
  ThisResource(label, numID, this._selfSignKeyPair, this._userSignKeyPair) : super(label, numID){
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
/// This is for when the user wants name part of their label
makeThisResource() async {
  final signatureAlgorithm = Ed25519();
  final selfSignKeyPair = signatureAlgorithm.newKeyPair();
  final userSignKeyPair = signatureAlgorithm.newKeyPair();
  ///XEP-0384 Says Resource ID must be *unique*, probably means to bareJID
  return ThisResource('ComChest',
      rng.nextInt(pow(2, 32).toInt()).toString(),
      selfSignKeyPair,
      userSignKeyPair);
}


