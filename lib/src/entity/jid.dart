import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';
import 'package:xmpp_defi/src/entity/resource.dart';
import 'package:xmpp_defi/src/entity/domain.dart';

class BareJID{
  String user;
  Domain domain;
  String get bareJID {
    return user + "@" + domain.domainName;
  }
  BareJID(this.user, this.domain) {}
}

/// A typedef for [JID.getJID].
typedef fullJID = String Function();

/// Stands for Jabber ID (XMPP Address)
/// We use username@domain/resource and username is user@domain
/// ```dart
///  JID otherJID = new JID(otherUser, otherDomain, otherResource)
/// ```

class JID extends BareJID{
  Resource _resource;

  String get fullJID {
    return user + "@" + domain.domainName +"/" + _resource.label;
  }
  JID(super.user, super.domain, this._resource);

}

class JIDResources extends BareJID{
  List<Resource> _resources;
  Map<BareJID, List<Resource>> contactsSIDs = Map();
  Map<BareJID, List<Resource>> contactsFIDs =  Map();

  JIDResources(String user, Domain domain, this._resources) : super(user, domain) {}
}

class SocialID extends JID{
  Map<String, List<Resource>> contactsSIDs = Map();
  SocialID(super.user,
      super.domain,
      super._resource){}
}

/* class MySID extends SocialID{
  MySID(String user, Domain domain, this._selfKeyPair, this._userKeyPair, {String resource = 'ComChest'}) : super(user, domain) {
  }

}
*/


/*class MasterSID extends MySID{
  SimpleKeyPairData _masterKeyPair;
  // Sign
  MasterSID(String user,
      domain,
      _selfKeyPair, _userKeyPair, this._masterKeyPair, {String resource = 'ComChest'}) : super(user, domain, _selfKeyPair, _userKeyPair) {
    this.resource = resource + Random.secure().toString();
  }

  getPubMasterKey(){
    return _masterKeyPair.extractPublicKey();
  }

  signMaster(key){
      return signatureAlgorithm.sign([key], keyPair: _masterKeyPair);
  }
}*/

class FinID extends JID{
  var SecondarySIDs = new Map(); //For one time codes and security alerts
  FinID(user, domain, _resource) : super(user, domain, _resource) {}
}

class MyFID extends FinID{
  int pubkey;
  String PrimarySID;

  MyFID(user, domain, this.pubkey, this.PrimarySID, {resource}) : super(user, domain, resource) {

  }
}

MakeFID(domain, int public_key, PrimarySID, {String resourceName = 'ComChest'}) async {
  final hMAC = Hmac.sha256();
  final message = utf8.encode(domain);
  final pubKey = SecretKey([public_key]);
  final mac = await hMAC.calculateMac(message, secretKey: pubKey);
  return MyFID(base64.encode(mac.bytes).replaceAll(new RegExp(r'[^\w\s]+'), ''), domain, public_key, PrimarySID);
}

void main() async {
  var testFID = await MakeFID("cc.credit_union", 313691, "aeneas@comchest.org");
  print(testFID.user);
}
