import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';
import 'package:xmpp_defi/src/jid/resource.dart';


/// A typedef for [JID._shouldCascade].
typedef _ShouldCascade = bool Function(Response response);

/// A helper that calls several handlers in sequence and returns the first
/// acceptable response.
///
/// By default, a response is considered acceptable if it has a status other
/// than 404 or 405; other statuses indicate that the handler understood the
/// request.
///
/// If all handlers return unacceptable responses, the final response will be
/// returned.
///
/// ```dart
///  JID otherJID = new JID(otherUser, otherDomain, otherResource)
/// ```

class JID{
  String user;
  String domain;
  Resource _resource;
  List<Resource> _selfResources = [];
  Map<String, List<Resource>> contactsSIDs = Map();
  Map<String, List<Resource>> contactsFIDs =  Map();
  final signatureAlgorithm = Ed25519();

  JID(this.user, this.domain, this._resource) {}

  getJID(){
    return user + "@" + domain + "/" + _resource;
  }
}

class SocID extends JID{

  SocID(String user, String domain, Resource Resource) : super(user, domain, Resource) {

  }
}

MakeSID(String user, String domain, {resourceID = "ComChest"}){
  return SocID(user, domain, Resource(resourceID + Random.secure().toString()));
}

class MySID extends SocID{
  MySID(String user, String domain, this._selfKeyPair, this._userKeyPair, {String resource = 'ComChest'}) : super(user, domain) {
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

///By default encrypt MasterKey with ArgonID of password.
class MasterSID extends MySID{
  SimpleKeyPairData _masterKeyPair;
  // Sign
  MasterSID(user, domain, _selfKeyPair, _userKeyPair, this._masterKeyPair, {String resource = 'ComChest'}) : super(user, domain, _selfKeyPair, _userKeyPair) {
    this.resource = resource + Random.secure().toString();
  }

  getPubMasterKey(){
    return _masterKeyPair.extractPublicKey();
  }

  signMaster(key){
      return signatureAlgorithm.sign([key], keyPair: _masterKeyPair);
  }
}

class FinID extends JID{
  var SecondarySIDs = new Map();
  FinID(user, domain, _resource) : super(user, domain, _resource) {}
}

class MyFID extends FinID{
  int pubkey;
  String PrimarySID;
  
  MyFID(user, domain, this.pubkey, this.PrimarySID, {resource = 'ComChest'}) : super(user, domain) {

  }
}

MakeFID(domain, int public_key, PrimarySID, {String resourceName = 'ComChest'}) async {
  final hMAC = Hmac.sha256();
  final message = utf8.encode(domain);
  final pubKey = SecretKey([public_key]);
  final mac = await hMAC.calculateMac(message, secretKey: public_key);
  return MyFID(base64.encode(mac.bytes).replaceAll(new RegExp(r'[^\w\s]+'), ''), domain, public_key, PrimarySID);
}

void main() async {
  var testFID = await MakeFID("akcu.org", 313691, "aeneas@akcu.org");
  print(testFID.user);
}
