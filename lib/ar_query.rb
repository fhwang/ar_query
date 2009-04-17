class ARQuery < Hash
  attr_accessor :bind_vars, :boolean_join
  attr_reader   :condition_sqls, :joins
  
  def initialize(initial_values={})
    @initializing = true
    super nil
    initial_values.each do |k,v| self[k] = v; end
    @initializing = false
    @bind_vars = []
    @condition_sqls = ConditionSQLs.new
    @boolean_join = :and
    @joins = UniqueArray.new initial_values[:joins]
  end
    
  def []( key )
    if (key == :conditions) && !@condition_sqls.empty?
      join_str = @boolean_join == :and ? ' AND ' : ' OR '
      condition_sql =
          @condition_sqls.map { |c_sql| "(#{c_sql})" }.join(join_str)
      @bind_vars.empty? ? condition_sql : [ condition_sql, *@bind_vars ]
    elsif key == :joins
      @joins unless @joins.empty?
    else
      super
    end
  end
  
  def []=(key, value)
    @initializing ? super : raise(NoMethodError)
  end
  
  class ConditionSQLs < Array
    def <<(elt)
      if elt.is_a?(String)
        super
      else
        raise(
          ArgumentError,
          "Tried appending #{elt.inspect} to ARQuery#condition_sqls: Only strings are allowed"
        )
      end
    end
  end
  
  class UniqueArray < Array
    def initialize(values)
      super()
      if values
        values = [values] unless values.is_a?(Array)
        values.each do |value| self << value; end
      end
    end
    
    def <<(value)
      super
      uniq!
    end
  end
end
