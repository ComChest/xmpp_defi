import 'package:xmpp_defi/src/jid/jid.dart';
import 'package:xmpp_defi/src/jid/resource.dart';
import 'package:test/test.dart';

void main() async {
  var testFJID = await MakeFJID("akcu.org", 313691, "aeneas@akcu.org");
  print(testFJID.user);
}