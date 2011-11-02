require "inherited-hash/version"

module InheritedHash
  def inherited_hash_accessor *names
    names.each do |name|
      [self,class<<self;self;end].each do |context|
        context.send(%Q{instance_eval}.to_s) do
          define_method(name) do
            storage = %Q{@#{name}}.to_sym
            unless instance_variable_defined?( storage )
              instance_variable_set(storage, InheritedHash::ConnectedHash.new.connect(self,name))
            end
            instance_variable_get( storage)
          end
          define_method(%Q{#{name}!}.to_sym) do
            send(name).to_hash!
          end
          define_method(%Q{#{name}=}.to_sym) do |hsh|
            raise ArgumentError, 'Only hashes are allowed' unless hsh.is_a? Hash
            send(name).replace(hsh)
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
      hash = Hash.new
      @anchor.ancestors.reverse.each do |ancestor|
        hash.merge!(ancestor.send(@name).to_hash) if ancestor.respond_to?(@name)
      end
      hash
    end

    def to_hash
      Hash.new(&default_proc).replace(super)
    end

    def find_definition_of(key)
      verify!
      return @anchor if has_key? key
      return @anchor.class.send(@name).find_definition_of(key) unless @anchor.is_a? Module
      @anchor.ancestors.reverse.index do |ancestor|
        next false unless ancestor.respond_to?(@name)
        return ancestor if ancestor.send(@name).has_key?(key)
      end
    end
  end
end
