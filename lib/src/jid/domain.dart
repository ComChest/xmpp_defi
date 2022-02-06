import 'dart:math';

class Domain {
  String domainName;
  bool whiteListed = false;
  Domain(this.domainName){}
}

class FinancialDomain extends Domain{
  bool whiteListed = false;
  FinancialDomain(domainName) : super(domainName){}
}
