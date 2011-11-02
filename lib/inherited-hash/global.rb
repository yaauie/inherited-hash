require File.expand_path(File.join(File.dirname(__FILE__),'..','inherited-hash.rb'))

class Module
  include InheritedHash
end
