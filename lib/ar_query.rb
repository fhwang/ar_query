class ARQuery
  include Enumerable
  include ActiveSupport::CoreExtensions::Hash::Keys
  include ActiveSupport::CoreExtensions::Hash::Except
  
  attr_accessor :bind_vars, :boolean_join
  attr_reader   :condition_sqls, :joins
  
  def initialize(simple_values={})
    @simple_values = simple_values
    @bind_vars = []
    @condition_sqls = ConditionSQLs.new
    @boolean_join = :and
    @joins = UniqueArray.new simple_values[:joins]
  end
    
  def []( key )
    if (key == :conditions) && has_conditions?
      join_str = @boolean_join == :and ? ' AND ' : ' OR '
      condition_sql =
          @condition_sqls.map { |c_sql| "(#{c_sql})" }.join(join_str)
      @bind_vars.empty? ? condition_sql : [ condition_sql, *@bind_vars ]
    elsif key == :joins && has_joins?
      @joins
    else
      @simple_values[key]
    end
  end
  
  def delete(key)
    @simple_values.delete key
  end
  
  def initialize_copy(orig)
    super
    @simple_values = @simple_values.dup
  end
  
  def each
    keys.each do |key|
      yield key, self[key]
    end
  end
  
  def empty?
    keys.empty?
  end
  
  def has_conditions?
    !@condition_sqls.empty?
  end
  
  def has_joins?
    !@joins.empty?
  end
  
  def keys
    k = @simple_values.keys
    k << :conditions if has_conditions?
    k << :joins if has_joins?
    k.uniq
  end
  
  def is_a?(klass)
    (klass == Hash) ? true : super
  end
  
  def method_missing(sym, *args)
    if sym == :total_entries=
      @simple_values[:total_entries] = args.first
    else
      super
    end
  end
  
  def update(other_hash)
    @simple_values.update other_hash
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
