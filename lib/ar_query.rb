class ARQuery
  attr_reader :joins
  
  def initialize(simple_values={})
    @simple_values = simple_values
    @base_condition = Condition.new
    @joins = UniqueArray.new simple_values[:joins]
  end
  
  def has_joins?
    !@joins.empty?
  end

  def method_missing(sym, *args)
    if sym == :total_entries=
      @simple_values[:total_entries] = args.first
    elsif [:has_conditions?, :condition_sqls, :boolean_join=, :bind_vars,
           :bind_vars=].include?(sym)
      @base_condition.send(sym, *args)
    else
      super
    end
  end
  
  def nest_condition(&block)
    @base_condition.nest_condition do |nested|
      block.call nested
    end
  end
  
  def to_hash
    hash = @simple_values.dup
    hash[:conditions] = @base_condition.to_conditions if has_conditions?
    hash[:joins] = @joins if has_joins?
    hash
  end
  
  class Condition
    attr_accessor :bind_vars, :boolean_join
    attr_reader :condition_sqls
    
    def initialize
      @bind_vars = []
      @condition_sqls = SQLs.new
      @boolean_join = :and
      @children = []
    end
  
    def has_conditions?
      !@condition_sqls.empty?
    end
    
    def nest_condition(&block)
      @children << Condition.new
      yield @children.last
    end
    
    def to_conditions
      join_str = @boolean_join == :and ? ' AND ' : ' OR '
      binds = @bind_vars.dup || []
      condition_sql_fragments = @condition_sqls.map { |c_sql| "(#{c_sql})" }
      @children.each do |child|
        sub_conditions = child.to_conditions
        if sub_conditions.is_a?(Array)
          sql = sub_conditions.first
          sub_binds = sub_conditions[1..-1]
          condition_sql_fragments << "(#{sql})"
          binds.concat sub_binds
        else
          condition_sql_fragments << "(#{sub_conditions})"
        end
      end
      condition_sql = condition_sql_fragments.join(join_str)
      binds.empty? ? condition_sql : [ condition_sql, *binds ]
    end
  
    class SQLs < Array
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
