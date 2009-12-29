module Piglet
  module Relation
    attr_reader :sources

    def alias
      @alias ||= Relation.next_alias
    end
  
    # x.group(:a)                           # => GROUP x By a
    # x.group(:a, :b, :c)                   # => GROUP x BY (a, b, c)
    # x.group([:a, :b, :c], :parallel => 3) # => GROUP x BY (a, b, c) PARALLEL 3
    def group(*args)
      grouping, options = split_at_options(args)
      Group.new(self, [grouping].flatten, options)
    end
  
    # x.distinct                 # => DISTINCT x
    # x.distinct(:parallel => 5) # => DISTINCT x PARALLEL 5
    def distinct(options={})
      Distinct.new(self, options)
    end

    # x.cogroup(y, x => :a, y => :b)                 # => COGROUP x BY a, y BY b
    # x.cogroup([y, z], x => :a, y => :b, z => :c)   # => COGROUP x BY a, y BY b, z BY c
    # x.cogroup(y, x => [:a, :b], y => [:c, :d])     # => COGROUP x BY (a, b), y BY (c, d)
    # x.cogroup(y, x => :a, y => [:b, :inner])       # => COGROUP x BY a, y BY b INNER
    # x.cogroup(y, x => :a, y => :b, :parallel => 5) # => COGROUP x BY a, y BY b PARALLEL 5
    def cogroup; raise NotSupportedError; end
  
    # x.cross(y)                      # => CROSS x, y
    # x.cross(y, z, w)                # => CROSS x, y, z, w
    # x.cross([y, z], :parallel => 5) # => CROSS x, y, z, w PARALLEL 5
    def cross(*args)
      relations, options = split_at_options(args)
      Cross.new(([self] + relations).flatten, options)
    end
  
    # x.filter(:a.eql(:b))                   # => FILTER x BY a == b
    # x.filter(:a.gt(:b).and(:c.not_eql(3))) # => FILTER x BY a > b AND c != 3
    def filter; raise NotSupportedError; end
  
    # x.foreach { |r| r.a }            # => FOREACH x GENERATE a
    # x.foreach { |r| [r.a, r.b] }     # => FOREACH x GENERATE a, b
    # x.foreach { |r| r.a.max }        # => FOREACH x GENERATE MAX(a)
    # x.foreach { |r| r.a.avg.as(:b) } # => FOREACH x GENERATE AVG(a) AS b
    #
    # TODO: FOREACH a { b GENERATE c }
    def foreach; raise NotSupportedError; end
  
    # x.join(y, x => :a, y => :b)                        # => JOIN x BY a, y BY b
    # x.join([y, z], x => :a, y => :b, z => :c)          # => JOIN x BY a, y BY b, z BY c
    # x.join(y, x => :a, y => :b, :using => :replicated) # => JOIN x BY a, y BY b USING "replicated"
    # x.join(y, x => :a, y => :b, :parallel => 5)        # => JOIN x BY a, y BY b PARALLEL 5
    def join; raise NotSupportedError; end
  
    # x.limit(10) # => LIMIT x 10
    def limit(n)
      Limit.new(self, n)
    end
  
    # x.order(:a)                      # => ORDER x BY a
    # x.order(:a, :b)                  # => ORDER x BY a, b
    # x.order([:a, :asc], [:b, :desc]) # => ORDER x BY a ASC, b DESC
    # x.order(:a, :parallel => 5)      # => ORDER x BY a PARALLEL 5
    #
    # NOTE: the syntax x.order(:a => :asc, :b => :desc) would be nice, but in
    # Ruby 1.8 the order of the keys cannot be guaranteed.
    def order; raise NotSupportedError; end
  
    # x.sample(5) # => SAMPLE x 5;
    def sample(n)
      Sample.new(self, n)
    end
  
    # TODO: this one is tricky since it's assignment, but also a relation operation
    def split; raise NotSupportedError; end
  
    # x.stream(x, 'cut -f 3')                         # => STREAM x THROUGH `cut -f 3`
    # x.stream([x, y], 'cut -f 3')                    # => STREAM x, y THROUGH `cut -f 3`
    # x.stream(x, 'cut -f 3', :schema => [%w(a int)]) # => STREAM x THROUGH `cut -f 3` AS (a:int)
    #
    # TODO: how to handle DEFINE'd commands?
    def stream(relations, command, options={})
      raise NotSupportedError
    end
  
    # x.union(y)    # => UNION x, y
    # x.union(y, z) # => UNION x, y, z
    def union(*relations)
      Union.new(*([self] + relations))
    end

    def hash
      self.alias.hash
    end
  
    def eql?(other)
      other.is_a(Relation) && other.alias == self.alias
    end
  
  private

    def split_at_options(parameters)
      if parameters.last.is_a? Hash
        [parameters[0..-2], parameters.last]
      else
        [parameters, nil]
      end
    end

    def self.next_alias
      @counter ||= 0
      @counter += 1
      "relation_#{@counter}"
    end
  end
end