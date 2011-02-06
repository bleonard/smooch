require "spec_helper"

class TestSmooch < Smooch::Base
  @@cookies = {}
  # override stuff provided by controller
  def get_cookie(key)
    @@cookies[key]
  end
  def set_cookie(key, name)
    @@cookies[key] = name
  end
end

describe TestSmooch do

  describe "#ab" do
    before(:each) do
      @km = TestSmooch.new
      @val = @km.ab("Signup Button Color", ["red", "green"])
    end
    it "should return one of the variants" do
      (@val=="red" || @val=="green").should == true
    end
    it "should always be the same" do
      30.times do
        @km.ab("Signup Button Color", ["red", "green"]).should == @val
      end
    end
    it "should persist across sessions" do
      30.times do
        TestSmooch.new.ab("Signup Button Color", ["red", "green"]).should == @val
      end
    end
    it "should adjust when options change" do
      @val = @km.ab("Signup Button Color", ["blue", "brown", "orange"])
      (@val=="blue" || @val=="brown" || @val=="orange").should == true
      @km.ab("Signup Button Color", ["blue", "brown", "orange"]).should == @val
    end
    it "should return previous value without choices" do
      @km.ab("Signup Button Color").should == @val
      TestSmooch.new.ab("Signup Button Color").should == @val
    end
  end
end