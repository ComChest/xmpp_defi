import 'package:pointycastle/export.dart';
import "package:pointycastle/pointycastle.dart";
import 'dart:math';
import 'dart:convert';

class JID{
  String user;
  String domain;
  String resource;


  JID(this.user, this.domain, {this.resource = 'comchest'}) {
    this.user = user;
    this.domain = domain;
    this.resource = resource + Random.secure().toString()
  }

  AuthenticationResult(user, domain)
}

class SocialJID extends JID{
  FinJID(user, domain, {String resource = 'comchest'}) : super(user, domain) {
    this.user = user;
    this.domain = domain;
    this.resource = resource + Random.secure().toString()
  }
}

class FinJID extends JID{
  int pubkey;
  String digestID;

  FinJID(user, domain, this pubkey, {String resource = 'comchest'}) : super(user, domain) {
    this.user = user;
    this.domain = domain;
    this.resource = resource + Random.secure().toString()
    Argon2BytesGenerator argon = Argon2BytesGenerator();
    //this.digest = argon.deriveKey(inp, , out, outOff).toString()

  }
}

void main() {
  JID c1 = new JID('aeneas', 'akcu.org');
}