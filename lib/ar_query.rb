require 'delegate'

class ARQuery < DelegateClass( Hash )
  attr_accessor :bind_vars
  attr_reader   :condition_sqls
  
  def initialize(initial_values={})
    super
    @bind_vars = []
    @condition_sqls = []
  end
    
  def []( key )
    if (key == :conditions) && !@condition_sqls.empty?
      condition_sql =
          @condition_sqls.map { |c_sql| "(#{c_sql})" }.join( ' AND ' )
      @bind_vars.empty? ? condition_sql : [ condition_sql, *@bind_vars ]
    else
      super
    end
  end
end
