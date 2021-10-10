import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';\=

class Resource{ //AKA Device
  String label = 'ComChest';
  var rng = new Random();
  int ID = rng.nextInt(pow(2, 32).toInt(); //XEP-0384 Says it must be unique, probably to bareJID but we will check domain too
  List<String> _selfFJIDs = [];
  List<String> _selfSJIDs = [];
  final signatureAlgorithm = Ed25519();
  var userPublicKeys = new Map();
  var userKeySignatures = new Map();
  Resource(){}
  Resource(this.Label){}
  Resource(this.Label, this.ID){}
}

class makeResource(String resourceLabel){
  return Resource(resourceLabel))
}

class KeyedResource extends Resource{
  SimplePublicKey publicKey;
  Map<List<int>, Signature> msgSignatures = new Map();
  KeyedResource(String resourceID, this.publicKey) : super(resourceID){}
}

class ThisResource extends Resource{
  SimpleKeyPair _selfSignKeyPair;
  SimpleKeyPair _userSignKeyPair;
  Map<String, KeyedResource>
  selfPublicKeys = new Map();
  var selfKeySignatures = new Map();
  ThisResource(String resourceID, this._selfSignKeyPair, this._userSignKeyPair) : super(resourceID){
  }

  getPubSelfKey(){
    return _selfSignKeyPair.extractPublicKey();
  }

  getPubUserKey(){
    return _userSignKeyPair.extractPublicKey();
  }

  signSelf(self){
    return signatureAlgorithm.sign([self], keyPair: _selfSignKeyPair);
  }

  signUser(user){
    return signatureAlgorithm.sign([user], keyPair: _userSignKeyPair);
  }
}

