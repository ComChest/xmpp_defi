import 'dart:math';


class Domain {
  String domainName;
  bool whiteListed = false;
  Domain(this.domainName){}
}

class FinancialDomain extends Domain{
  String domainName;
  bool whiteListed = false;
  FinancialDomain(this.domainName){}
}