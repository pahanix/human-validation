class SymbolProxy
  def initialize(symbol)
    @symbol = symbol
    @options = {}
  end

  # Service methods

  def to_sym; @symbol; end
  def to_s; @symbol.to_s; end

  def belongs_to(*symbols)
    symbols.include?(@symbol)
  end
  private :belongs_to

  def extract
    [@symbol, @options]
  end
  alias_method :to_a, :extract
  
  # GLOBAL_METHODS = [:as, :is, :if, :unless, :on, :message, :or_nil, :or_blank]
  # UNIQ_METHODS = [:case_sensitive, :scope]
  # LENGTH_METHODS = [:in, :within, :is, :of, :min, :max]
  # FORMAT_METHODS = [:with, :within, :from]
  # NUMERIC_METHODS = [:only_integer, :greater_than, :greater_than_or_equal_to, :equal_to, :less_than, :less_than_or_equal_to, :odd, :even]
  
  # Basic methods
  
  # :symbol.as(...)
  def as(name=nil)
    @options.merge! :as => name
    self
  end

  # :symbol.message(...)
  def message(msg=nil)
    @options.merge! :message => msg
    self
  end
  
  # :uniq.case_sensitive(...)
  def case_sensitive(message=nil)
    # method_missing(:case_sensitive) unless belongs_to(:uniq)
    raise NoMethodError, "undefined method `case_sensitive' for :#{self}:Symbol" unless belongs_to(:uniq)
    @options.merge! :case_sensitive => true
    @options.merge! :message => message if message    
    self
  end
  
  # :uniq.scope(...)
  def scope(*args)
    raise NoMethodError, "undefined method `scope' for :#{self}:Symbol" unless belongs_to(:uniq)
    message = args.last.is_a?(String) ? args.pop : nil
    scope = args.size <= 1 ? args.first : args
    @options.merge! :message => message if message
    @options.merge! :scope => scope if scope
    self
  end
  
  # :legth.in(...)
  def in(range, message=nil)
    raise ArgumentError, ":length.in(range) accepts Range as parameter" unless range.kind_of?(Range)
    raise NoMethodError, "undefined method `in' for :#{self}:Symbol" unless belongs_to(:length)
    @options.merge! :in => range
    @options.merge! :message => message if message        
    self
  end

  # :length.min(...)
  def min(minimum, message=nil)
    raise NoMethodError, "undefined method `min' for :#{self}:Symbol" unless belongs_to(:length)
    @options.merge! :minimum => minimum
    @options.merge! :too_short => message if message        
    self
  end
  
  # :length.max(...)
  def max(maximum, message=nil)
    raise NoMethodError, "undefined method `max' for :#{self}:Symbol" unless belongs_to(:length)
    @options.merge! :maximum => maximum
    @options.merge! :too_long => message if message        
    self
  end
  
  # :length.within(...)
  def within(*args)
    raise NoMethodError, "undefined method `within' for :#{self}:Symbol" unless belongs_to(:length)
    raise ArgumentError, "wrong number of arguments (#{args.size} for 3) for :#{self}:Symbol" if args.size > 3 || args.size < 1
    range = args.shift
    raise TypeError, "can't convert #{range.class} to Range for :#{self}:Symbol" unless range.kind_of?(Range)

    @options.merge! :within => range
    if options = args.size == 1 
      options = args.first
      @options.merge! options.is_a?(String) ? {:too_short => options } : options
    else 
      @options.merge! :too_short => args.first if args.first
      @options.merge! :too_long => args.last  if args.last
    end    
    self
  end
  
  
  # :symbol.is(...) | :length.is(...)
  def is(*args)
    extracted = if belongs_to(:length) && args.size == 1 && args.first.is_a?(Fixnum)
      # country.is :length.is(5)
      args.first
    else
      # :length.is(:uniq, :numeric)
      args.map{ |i| i.extract }
    end
    @options.merge! :is => extracted
    self
  end
end

# Symblo core extention
class Symbol 
  def method_missing(method_name, *args)
    symbol_proxy = SymbolProxy.new(self)
    symbol_proxy.respond_to?(method_name) ? symbol_proxy.send(method_name, *args) : super
  end  
end
