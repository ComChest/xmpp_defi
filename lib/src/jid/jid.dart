import 'dart:html';
import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';
import 'package:xmpp_defi/resource.dart';

import 'package:cryptography/dart.dart';


class JID{
  String user;
  String domain;
  Resource _resource;
  List<Resource> _selfResources = [];
  Map<String, List<Resource>> contactsSJIDs = Map();
  Map<String, List<Resource>> contactsFJIDs =  Map();
  final signatureAlgorithm = Ed25519();

  JID(this.user, this.domain, this._resource) {}

  getJID(){
    return user + "@" + domain + "/" + _resource;
  }
}

class SocialJID extends JID{

  SocialJID(String user, String domain, Resource Resource) : super(user, domain, Resource) {

  }
}

MakeSJID(String user, String domain, {resourceID = "Comchest"}){
  return SocialJID(user, domain, Resource(resourceID + Random.secure().toString()));
}

class MySJID extends SocialJID{
  MySJID(String user, String domain, this._selfKeyPair, this._userKeyPair, {String resource = 'Comchest'}) : super(user, domain) {
  }

  getPubSelfKey(){
    return _selfKeyPair.extractPublicKey();
  }

  getPubUserKey(){
    return _userKeyPair.extractPublicKey();
  }

  signSelf(self){
    return signatureAlgorithm.sign([self], keyPair: _selfKeyPair);
  }

  signUser(user){
    return signatureAlgorithm.sign([user], keyPair: _userKeyPair);
  }

}

class MasterSJID extends MySJID{ //ByDefault encrypt MasterKey with ArgonID of password.
  SimpleKeyPairData _masterKeyPair;
  // Sign
  MasterSJID(user, domain, _selfKeyPair, _userKeyPair, this._masterKeyPair, {String resource = 'Comchest'}) : super(user, domain, _selfKeyPair, _userKeyPair) {
    this.resource = resource + Random.secure().toString();
  }

  getPubMasterKey(){
    return _masterKeyPair.extractPublicKey();
  }

  signMaster(key){
      return signatureAlgorithm.sign([key], keyPair: _masterKeyPair);
  }
}

class FinJID extends JID{
  var SecondarySJIDs = new Map();
  FinJID(user, domain, _resource) : super(user, domain, _resource) {}
}

class MyFJID extends FinJID{
  int pubkey;
  String PrimarySJID;


  MyFJID(user, domain, this.pubkey, this.PrimarySJID, {resource = 'Comchest'}) : super(user, domain) {

  }

}

MakeFJID(domain, int pubkey, PrimarySJID, {String resourceName = 'ComChest'}) async {
  final hmac = Hmac.sha256();
  final message = utf8.encode(domain);
  final pubKey = SecretKey([pubkey]);
  final mac = await hmac.calculateMac(message, secretKey: pubKey);
  return MyFJID(base64.encode(mac.bytes).replaceAll(new RegExp(r'[^\w\s]+'), ''), domain, pubkey, PrimarySJID);
}

void main() async {
  var testFJID = await MakeFJID("akcu.org", 313691, "aeneas@akcu.org");
  print(testFJID.user);
}
