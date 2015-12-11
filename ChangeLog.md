### 0.1.4 / 2015-12-10

* Prioritize TXT records on `_spf.example.com` and `example.com` over a SPF
  record on `example.com`. [RFC 7208] deprecated SPF-type records.
  (@nandosousafr)

### 0.1.3 / 2015-10-19

* Join multi-part DNS responses together with a `' '` instead of nothing.

### 0.1.2 / 2015-07-07

#### parser

* Convert all chars and literals to Strings.
* Properly transform macro_strings that contain a single literal into a String.

### 0.1.1 / 2015-07-06

* Raise {SPF::Query::SenderIDFound} from {SPF::Query::Record.parse} if
  [Sender ID](http://www.openspf.org/SPF_vs_Sender_ID) is detected.

### 0.1.0 / 2015-07-01

* Initial release:
  * Queries and parses SPF records.
  * Supports querying both TXT and SPF records.

[RFC 7208]: https://tools.ietf.org/html/rfc7208#section-3.1
