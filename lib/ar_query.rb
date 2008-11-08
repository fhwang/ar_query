require 'delegate'

class ARQuery < DelegateClass( Hash )
  def initialize( initial_values ); super( initial_values ); end
    
  def []( key )
    if (key == :conditions) && @condition_sqls
      @condition_sqls.map { |c_sql| "(#{c_sql})" }.join( ' AND ' )
    else
      super
    end
  end
    
  def condition_sql=( c_sql )
    if @condition_sqls
      raise "You already initialized condition_sql, maybe you want to call condition_sql << instead?"
    end
    @condition_sqls = [ c_sql ]
  end
  
  def condition_sql
    @condition_sqls ||= [ ]
  end
end
