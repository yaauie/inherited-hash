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
      # connect this object to a class or instance by name
      self
    end

    def to_hash!
      # get a normal hash, following inheritance tree
    end

    def to_hash
      # get a normal hash
    end

    def find_definition_of(key)
      # return the object (class or instance) that 
      # defined the key that results in the current value
    end
  end
end
