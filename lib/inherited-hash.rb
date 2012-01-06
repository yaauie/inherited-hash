require "inherited-hash/version"

module InheritedHash
  def self.extended(base)
    base.send(:include, InstanceMethods)
    base.extend ClassMethods
  end
  
  module InstanceMethods
    def inherited_hashes
      @inherited_hashes ||= Hash.new do |h,name|
        h[name] = ConnectedHash.new.connect(self,name)
      end
    end  
  end

  module ClassMethods
    include InstanceMethods

    def inherited_hash_accessor *names
      names.each do |name|
        [self,class<<self;self;end].each do |context|
          context.send(%Q{instance_eval}.to_s) do
            define_method(name) do
              inherited_hashes[name]
            end
            define_method(%Q{#{name}!}.to_sym) do
              inherited_hashes[name].to_hash!
            end
            define_method(%Q{#{name}=}.to_sym) do |hsh|
              raise ArgumentError, 'Only hashes are allowed' unless hsh.is_a? Hash
              inherited_hashes[name].replace(hsh)
            end
          end
        end
      end
    end
  end

  class ConnectedHash < Hash
    def connect(anchor,name)
      @anchor, @name = anchor, name
      self
    end

    def verify!
      raise Exception, "#{self.inspect} must be connected!" unless @anchor and @name
    end

    def to_hash!
      verify!
      return @anchor.class.send(%Q{#{@name}!}.to_sym).merge(self.to_hash) unless @anchor.is_a? Module

      @anchor.ancestors.reverse.map do |ancestor|
        next nil unless ancestor.respond_to?(:inherited_hashes)
        ancestor.inherited_hashes[@name].to_hash
      end.compact.reduce({},:merge)
    end

    def to_hash
      Hash.new(&default_proc).replace(super)
    end

    def find_definition_of(key)
      verify!
      return @anchor if has_key? key
      return @anchor.class.send(@name).find_definition_of(key) unless @anchor.is_a? Module
      @anchor.ancestors.reverse.index do |ancestor|
        next nil unless ancestor.respond_to?(:inherited_hashes)
        return ancestor if ancestor.inherited_hashes[@name].has_key?(key)
      end
    end
  end
end
