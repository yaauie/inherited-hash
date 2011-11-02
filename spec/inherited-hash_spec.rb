require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'InheritedHash' do
  describe '#inherited_hash_accessor' do
    subject do
      Class.new do
        extend InheritedHash
        inherited_hash_accessor :foo
      end
    end

    it 'should create accessor methods in instances' do
      subject.new.should respond_to :foo
      subject.new.should respond_to :foo!
    end

    it 'should create accessor methods in the class' do
      subject.should respond_to :foo
      subject.should respond_to :foo!
    end
  end
  context 'an inherited stack' do
    before :each do
      @s = Hash.new
      @s[:root] = Class.new do
        extend InheritedHash
        inherited_hash_accessor :foo,:bar

        self.foo={
          :not_overridden => "don't override me",
          :existing_key => 'unchanged'
        }
      end
      @s[:leaf1] = Class.new(@s[:root]) do
        foo[:new_key] = 'brand new'
        foo[:existing_key] = 'changed'
      end
      @s[:leaf2] = Class.new(@s[:root]) do
      end
      @s[:leaf2_shoot1] = Class.new(@s[:leaf2]) do
        foo[:existing_key] = 'changed!'
      end

      @s
    end

    context 'in root class' do
      subject {@s[:root]}

      it 'should be directly accessible' do
        subject.foo[:existing_key].should == 'unchanged'
        subject.foo[:not_overridden].should == "don't override me"
      end

      it 'should not be overridden' do
        subject.foo[:new_key].should be_nil
      end
    end

    context 'in extended class' do
      subject {@s[:leaf1]}

      it 'should be directly accessible' do
        subject.foo[:new_key].should == 'brand new'
        subject.foo[:existing_key].should == 'changed'
        subject.foo[:not_overridden].should be_nil
      end
      it 'should be able to access inheritance' do
        subject.foo![:new_key].should == 'brand new'
        subject.foo![:existing_key].should == 'changed'
        subject.foo![:not_overridden].should == "don't override me"
      end

      context 'instance' do
        subject do
          s = @s[:leaf1].new
          s.foo = {:another_new_key => 'ooh, shiny'}
          s
        end
        it 'should have access to instance-set key' do
          subject.foo![:another_new_key].should == 'ooh, shiny'
        end
        it 'should have access to keys inherited from class' do
          subject.foo![:existing_key].should == 'changed'
        end
        it 'should have access to keys inherited from root' do
          subject.foo![:not_overridden].should == "don't override me"
        end
        it 'should be able to find the definition in the object' do
          subject.foo.find_definition_of(:another_new_key).should be subject
        end
        it 'should be able to find the definition in the class' do
          subject.foo.find_definition_of(:new_key).should be subject.class
          subject.foo.find_definition_of(:existing_key).should be subject.class
        end
        it 'should be able to find the definition in the root' do
          subject.foo.find_definition_of(:not_overridden).should be @s[:root]
        end
        it 'should not be able to find a definition that does not exist' do
          subject.foo.find_definition_of(:not_exist).should be_nil
        end
      end
    end

  end
end
