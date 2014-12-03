# spf-query

[![Code Climate](https://codeclimate.com/github/trailofbits/spf-query/badges/gpa.svg)](https://codeclimate.com/github/trailofbits/spf-query)
[![Test Coverage](https://codeclimate.com/github/trailofbits/spf-query/badges/coverage.svg)](https://codeclimate.com/github/trailofbits/spf-query)
[![Build Status](https://travis-ci.org/trailofbits/spf-query.svg)](https://travis-ci.org/trailofbits/spf-query)

The `spf-query` library searches the spf records for a host. We assume the host uses standard spf 'selectors', and also check if they use their own 'selector'.

## Examples

###CLI
___
-use a single domain

    spf-query google.com
    ____________________________
    SPF record search for google.com
      - found SPF record for google.com at google.com:
      v=spf1 include:_spf.google.com ip4:216.73.93.70/31 ip4:216.73.93.72/31 ~all
    ____________________________


-or a bunch in a row

    spf-query trailofbits.com facebook.com yahoo.com
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

    require 'spf/query'
    
    SPF::Query::Record.query('twitter.com')
    => #<SPF::Query::Record:0x00000002177440 @version=:spf1, @rules=[#<SPF::Query::Directive:0x00000001ffbdf0 @name=:ip4, @value=#<SPF::Query::IP:0x00000001fed408 @address="199.16.156.0"@11, @cidr_length=22>, @qualifier=nil>, #<SPF::Query::Directive:0x00000001ff8358 @name=:ip4, @value=#<SPF::Query::IP:0x00000001ff9870 @address="199.59.148.0"@31, @cidr_length=22>, @qualifier=nil>, #<SPF::Query::Directive:0x00000001ffc750 @name=:ip4, @value=#<SPF::Query::IP:0x00000001ffdcb8 @address="8.25.194.0"@51, @cidr_length=23>, @qualifier=nil>, #<SPF::Query::Directive:0x00000002106998 @name=:ip4, @value=#<SPF::Query::IP:0x00000002001728 @address="8.25.196.0"@69, @cidr_length=23>, @qualifier=nil>, #<SPF::Query::Directive:0x0000000212a230 @name=:ip4, @value=#<SPF::Query::IP:0x0000000212ba40 @address="204.92.114.203"@87, @cidr_length=nil>, @qualifier=nil>, #<SPF::Query::Directive:0x00000002141a48 @name=:ip4, @value=#<SPF::Query::IP:0x00000002142f60 @address="204.92.114.204"@106, @cidr_length=31>, @qualifier=nil>, #<SPF::Query::Directive:0x0000000214abe8 @name=:ip4, @value=#<SPF::Query::IP:0x00000002140170 @address="107.20.52.15"@128, @cidr_length=nil>, @qualifier=nil>, #<SPF::Query::Directive:0x00000002157d98 @name=:ip4, @value=#<SPF::Query::IP:0x00000002149310 @address="23.21.83.90"@145, @cidr_length=nil>, @qualifier=nil>, #<SPF::Query::Directive:0x00000002163918 @name=:include, @value="_spf.google.com"@165, @qualifier=nil>, #<SPF::Query::Directive:0x0000000216b4b0 @name=:include, @value="_thirdparty.twitter.com"@189, @qualifier=nil>, #<SPF::Query::Directive:0x00000002168b20 @name=:all, @value=nil, @qualifier=:fail>]>
        

## Install

    $ gem install spf-query

## License

See the {file:LICENSE.txt} file.
