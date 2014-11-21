# dkim_parse

[![Code Climate](https://codeclimate.com/github/trailofbits/dkim_parse.png)](https://codeclimate.com/github/trailofbits/dkim_parse) [![Build Status](https://travis-ci.org/trailofbits/dkim_parse.svg)](https://travis-ci.org/trailofbits/dkim_parse)
[![Test Coverage](https://codeclimate.com/github/trailofbits/dkim_parse/badges/coverage.svg)](https://codeclimate.com/github/trailofbits/dkim_parse)

The `dkim_parse` library searches the dkim records for a host. We assume the host uses standard dkim 'selectors', and also check if they use their own 'selector'.

## Examples

###CLI
___
-use a single domain

    spf google.com
    ____________________________
    SPF record search for google.com
      - found SPF record for google.com at google.com:
      v=spf1 include:_spf.google.com ip4:216.73.93.70/31 ip4:216.73.93.72/31 ~all
    ____________________________


-or a bunch in a row

    spf trailofbits.com facebook.com yahoo.com
    ____________________________
    SPF record search for trailofbits.com
      - found SPF record for trailofbits.com at trailofbits.com:
      v=spf1 include:_spf.google.com ~all
    ____________________________

    ____________________________
    SPF record search for facebook.com
      - found SPF record for facebook.com at facebook.com:
      v=spf1 redirect=_spf.facebook.com
    ____________________________

    ____________________________
    SPF record search for yahoo.com
      - found SPF record for yahoo.com at yahoo.com:
      v=spf1 redirect=_spf.mail.yahoo.com
    ____________________________

###In a project
___
    require 'spf_parse'
    
    SpfParse.check_host('twitter.com')
     => {:record=>"v=spf1 ip4:199.16.156.0/22 ip4:199.59.148.0/22 ip4:8.25.194.0/23 ip4:8.25.196.0/23 ip4:204.92.114.203 ip4:204.92.114.204/31 ip4:107.20.52.15 ip4:23.21.83.90 include:_spf.google.com include:_thirdparty.twitter.com -all", :record_path=>"twitter.com"}
        

## Install

    rake install

## License

See the {file:LICENSE.txt} file.
