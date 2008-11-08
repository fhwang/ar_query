require File.dirname(__FILE__) + '/../lib/ar_query'

describe ARQuery do
  describe '#initialize' do
    before :all do
      @ar_query = ARQuery.new :per_page => 10
    end
    
    it 'should set an initial value' do
      @ar_query[:per_page].should == 10
    end
    
    it 'should return nil conditions by default' do
      @ar_query[:conditions].should be_nil
    end
  end
  
  describe "#conditions" do
    describe "starting with #condition_sql=" do
      before :all do
        @ar_query = ARQuery.new :per_page => 10
        @ar_query.condition_sql = "fname is not null"
        @ar_query.condition_sql << "lname is not null"
      end
      
      it 'should join the conditions with an AND' do
        @ar_query[:conditions].should ==
            "(fname is not null) AND (lname is not null)"
      end
    end
    
    describe "starting with #condition_sql <<" do
      before :all do
        @ar_query = ARQuery.new :per_page => 10
        @ar_query.condition_sql << "fname is not null"
        @ar_query.condition_sql << "lname is not null"
      end
      
      it 'should join the conditions with an AND' do
        @ar_query[:conditions].should ==
            "(fname is not null) AND (lname is not null)"
      end
    end
    
    describe "trying to call #condition_sql= after the first #condition_sql call" do
      it 'should raise an error' do
        lambda {
          @ar_query = ARQuery.new :per_page => 10
          @ar_query.condition_sql << "fname is not null"
          @ar_query.condition_sql = "lname is not null"
        }.should raise_error(
          RuntimeError,
          /You already initialized condition_sql, maybe you want to call condition_sql << instead\?/
        )
      end
    end
  end
end
