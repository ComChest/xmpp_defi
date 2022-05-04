import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:convert';
//import 'package:xmpp_defi/src/jid/jid.dart';
//import 'package:xmpp_defi/src/jid/resource.dart';
//import 'package:test/test.dart';

final signatureAlgorithm = Ed25519();

Future<void> main() async {
  /*
  final masterSignKeyPair = signatureAlgorithm.newKeyPair();
  print(masterSignKeyPair.toString());
  signature = signatureAlgorithm.sign(List[1], masterSignKeyPair)
  print('Signature: ${signature.bytes}');
  print('Public key: ${signature.publicKey.bytes}');
  final selfSignKeyPair = signatureAlgorithm.newKeyPair();
  print(selfSignKeyPair.toString());
  final userSignKeyPair = signatureAlgorithm.newKeyPair();
  print(userSignKeyPair.toString());
  */
}