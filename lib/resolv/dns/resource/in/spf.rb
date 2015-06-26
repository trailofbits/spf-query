require 'resolv'

class Resolv::DNS::Resource::IN::SPF < Resolv::DNS::Resource::IN::TXT
  # resolv.rb doesn't define an SPF resource type.
  TypeValue = 99
  ClassValue = Resolv::DNS::Resource::IN::ClassValue

  Resolv::DNS::Resource::ClassHash[[TypeValue, ClassValue]] = self
end
