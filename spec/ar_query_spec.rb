require File.dirname(__FILE__) + '/../lib/ar_query'

describe ARQuery do
  describe '#initialize with no values' do
    before :all do
      @ar_query = ARQuery.new
    end
    
    it 'should not have conditions' do
      @ar_query[:conditions].should be_nil
    end
  end
  
  describe "#condition_sqls <<" do
    before :all do
      @ar_query = ARQuery.new
      @ar_query.condition_sqls << "fname is not null"
      @ar_query.condition_sqls << "lname is not null"
    end
    
    it 'should join the conditions with an AND' do
      @ar_query[:conditions].should ==
          "(fname is not null) AND (lname is not null)"
    end
  end
  
  describe '#condition_sqls << with OR as the boolean join' do
    before :all do
      @ar_query = ARQuery.new
      @ar_query.boolean_join = :or
      @ar_query.condition_sqls << "fname is not null"
      @ar_query.condition_sqls << "lname is not null"
    end
    
    it 'should join the conditions with an OR' do
      @ar_query[:conditions].should ==
          "(fname is not null) OR (lname is not null)"
    end
  end
    
  describe '[:conditions]' do
    describe 'with bind vars' do
      before :all do
        @ar_query = ARQuery.new
        @ar_query.condition_sqls << "fname = ?"
        @ar_query.condition_sqls << "lname = ?"
      end
      
      describe 'using appends' do
        before :all do
          @ar_query.bind_vars << 'Francis'
          @ar_query.bind_vars << 'Hwang'
        end
        
        it 'should put the bind_vars at the end of the conditions array' do
          @ar_query[:conditions].should ==
            [ "(fname = ?) AND (lname = ?)", 'Francis', 'Hwang' ]
        end
      end
      
      describe 'using assignment' do
        before :all do
          @ar_query.bind_vars = %w( Francis Hwang )
        end
        
        it 'should put the bind_vars at the end of the conditions array' do
          @ar_query[:conditions].should ==
            [ "(fname = ?) AND (lname = ?)", 'Francis', 'Hwang' ]
        end
      end
    end
  end
end
