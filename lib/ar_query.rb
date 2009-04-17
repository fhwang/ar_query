class ARQuery
  attr_accessor :bind_vars, :boolean_join
  attr_reader   :condition_sqls, :joins
  
  def initialize(simple_values={})
    @simple_values = simple_values
    @bind_vars = []
    @condition_sqls = ConditionSQLs.new
    @boolean_join = :and
    @joins = UniqueArray.new simple_values[:joins]
  end

  def conditions
    join_str = @boolean_join == :and ? ' AND ' : ' OR '
    condition_sql = @condition_sqls.map { |c_sql| "(#{c_sql})" }.join(join_str)
    @bind_vars.empty? ? condition_sql : [ condition_sql, *@bind_vars ]
  end

  def has_conditions?
    !@condition_sqls.empty?
  end
  
  def has_joins?
    !@joins.empty?
  end

  def method_missing(sym, *args)
    if sym == :total_entries=
      @simple_values[:total_entries] = args.first
    else
      super
    end
  end
  
  def to_hash
    hash = @simple_values.dup
    hash[:conditions] = conditions if has_conditions?
    hash[:joins] = @joins if has_joins?
    hash
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
