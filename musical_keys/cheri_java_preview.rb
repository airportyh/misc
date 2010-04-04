#
# Module(s): Cheri::Java, with extensions to Ruby
# classes Array, Numeric, Object and String
#
# Author: Bill Dortch <bill.dortch@gmail.com>
#
# Version: 0.0.1 Pre-Alpha Feature Preview 2 (will supersede JRBuilder-0.1.0 when complete)
# Released: 14 February 2007
# 
# Copyright (C) 2007 William N Dortch <bill.dortch@gmail.com>
# 
# License: GPL/CPL; see file LICENSE for details (same as JRuby)
# 
# License in plain English: Do as you wish with this
# software, but please leave this notice on it. The code
# is most certainly buggy, so use it at you own risk.
# 
# See http://www2.webng.com/bdortch/cherry/ for sample usage
# 
require 'java'
#require 'thread'

module Cheri
class << self
def threadsafe
  false
end
def add_type_converter(*args,&block)
  Java::Types.add_converter(*args,&block)
end
end #self
module Java
# a note on using constants for packages and classes
# 1. using constants for package names is faster than specifying
# fully-qualified class names, not by a lot, but it adds up.
# For example, if JLang is set to java.lang,
#   cls = JLang.Object
# is 10% faster than
#   cls = java.lang.Object
# (note that this will vary with the number of nodes in the package name;
# org.my.very.very.long.winded.package.name.AndFinallyAClass will benefit even more)
# 2. using constants for class names is *hugely* faster. For example,
#   cls = JObject
# is 35 *times* faster (3500%) than
#   cls = java.lang.Object
# Keep this in mind if your application creates a lot of Java objects.
# Of course, even if it doesn't, it's still easier to type the constant names...
# On the downside, defining constants for classes, as below, entails some
# overhead as JRuby loads them and sets up their proxies.
JLang = java.lang
JObject = JLang.Object
JBoolean = JLang.Boolean
JByte = JLang.Byte
JCharacter = JLang.Character
JShort = JLang.Short
JInteger = JLang.Integer
JLong = JLang.Long
JFloat = JLang.Float
JDouble = JLang.Double
JString = JLang.String
JBigDecimal = java.math.BigDecimal
JBigInteger = java.math.BigInteger
Jboolean = JBoolean::TYPE
Jbyte = JByte::TYPE
Jchar = JCharacter::TYPE
Jshort = JShort::TYPE
Jint = JInteger::TYPE
Jlong = JLong::TYPE
Jfloat = JFloat::TYPE
Jdouble = JDouble::TYPE
JTrue = JBoolean::TRUE
JFalse = JBoolean::FALSE
SObject = 'java.lang.Object'.to_sym
SBoolean = 'java.lang.Boolean'.to_sym
SByte = 'java.lang.Byte'.to_sym
SCharacter = 'java.lang.Character'.to_sym
SShort = 'java.lang.Short'.to_sym
SInteger = 'java.lang.Integer'.to_sym
SLong = 'java.lang.Long'.to_sym
SFloat = 'java.lang.Float'.to_sym
SDouble = 'java.lang.Double'.to_sym
SString = 'java.lang.String'.to_sym
SBigDecimal = 'java.math.BigDecimal'.to_sym
SBigInteger = 'java.math.BigInteger'.to_sym


module Object
  def java_kind_of?(other)
    return true if self.kind_of?(other)
    return false unless self.respond_to?(:java_class) && other.respond_to?(:java_class) &&
      other.kind_of?(Module) && !self.kind_of?(Module) 
    return other.java_class.assignable_from?(self.java_class)
  end
  def java_string
    JString.new(self.to_s)  
  end
end #Object

module Numeric
  def java_boolean
    self == 0 ? JFalse : JTrue
  end
  def java_byte
    JByte.new(self)  
  end
  def java_short
    JShort.new(self)  
  end
  def java_char
    JCharacter.new(self)  
  end
  def java_int
    JInteger.new(self)  
  end
  def java_long
    JLong.new(self)  
  end
  def java_float
    JFloat.new(self)
  end
  def java_double
    JDouble.new(self)  
  end
  def java_decimal(context_or_scale = nil)
    if context_or_scale
      if self.kind_of?(Integer)
        if context_or_scale.kind_of?(Fixnum)
          JBigDecimal.valueOf(self,context_or_scale)
        else
          JBigDecimal.new(self,context_or_scale)
        end
      else
        JBigDecimal.new(self,context_or_scale)
      end
    else
      JBigDecimal.valueOf(self)    
    end
  end
  def java_big_int
    #JBigInteger.valueOf(self.to_i)
    # doing it this way because BigInteger.valueOf seems to
    # be broken in JRuby -- always returns a Fixnum (or possibly
    # a Bignum). Or maybe this is intentional?
    JBigInteger.new(self.to_s)
  end
end #Numeric

module String
  def java_byte
    # doesn't make sense to return a value for
    # an empty string
    return nil if self.length == 0
    JByte.new(self[0])  
  end
  def java_char
    # doesn't make sense to return a value for
    # an empty string
    return nil if self.length == 0
    # TODO: handling for multi-byte? depends on what
    # JRuby ends up doing about String representation
    JCharacter.new(self[0])  
  end
  def java_short
    JShort.new(self)  
  end
  def java_int
    JInteger.new(self)  
  end
  def java_long
    JLong.new(self)  
  end
  def java_float
    JFloat.new(self)
  end
  def java_double
    JDouble.new(self)  
  end
  def java_string
    JString.new(self)  
  end
  def java_boolean
    JBoolean.new(self)
  end
  def java_decimal(math_context = nil)
    math_context ? JBigDecimal.new(self,math_context) : JBigDecimal.new(self)
  end
  def java_big_int(radix = nil)
    radix ? JBigInteger.new(self,radix) : JBigInteger.new(self)
  end
end #String

module Array
  # note: cheap, but does not examine entire array
  # used for matching with methods/constructors
  # see note at Cheri::Java::Arrays.dimensionality
  def dimensionality
    Cheri::Java::Arrays.dimensionality(self)  
  end

  # note: very expensive; specify dimensions when possible
  # used when no dimensions specified in java_array call,
  # and when automatically converting an array before
  # a method/constructor call
  # see note at Cheri::Java::Arrays.dimensions
  def dimensions
    Cheri::Java::Arrays.dimensions(self)  
  end
  
  def java_array(*args,&block)
    Cheri::Java::Arrays.java_array(*(args.unshift(self)),&block)  
  end
end #Array

class Arrays
  JArray = java.lang.reflect.Array
  class << self

  # this only looks at array[... 0 ]..., e.g.,
  # dimensionality [[[1]]] #=> 3; but
  # dimensionality [0,[[[[[[1],[2],[3]]]]]] #=> 1
  # in general, n-dimensional Ruby arrays passed to
  # Cheri-managed ctors/methods need to be well-formed
  def dimensionality(array)
    dim = 0
    while array.kind_of?(::Array)
      dim += 1
      array = array[0]    
    end
    dim
  end

  # this is very expensive to calculate; whenever possible,
  # pass the desired dimensions to the java_array method, e.g.
  # my_array.java_array(:float,[3,3,3]} 
  def dimensions(array,dims = ::Array.new(dimensionality(array),0),index = 0)
    return [] unless array.kind_of?(::Array)
    # account for dimensions not detected by dimensionality()
    dims << 0 while dims.length <= index 
    dims[index] = array.length if array.length > dims[index]
    array.each do |sub_array|
      next unless sub_array.kind_of?(::Array)
      dims = dimensions(sub_array,dims,index+1)
    end
    dims
  end

  def java_array(*args,&block)
    # equivalent to Array.java_array(0)
    return JArray.newInstance(JObject,0) if args.length == 0
    ruby_array = args[0]
    unless ruby_array.kind_of?(::Array) || ruby_array.nil?
      raise ArgumentError,"invalid arg[0] passed to java_array (#{args[0]})"    
    end
    dims = nil
    fill_value = nil
    index = 1
    if index < args.length
      arg = args[index]
      # the (optional) first arg is class/name. if omitted,
      # defaults to java.lang.Object
      if arg.kind_of?(Class) && arg.respond_to?(:java_class)
        cls = arg
        cls_name = arg.java_class.name
        index += 1
      elsif arg.kind_of?(String) || arg.kind_of?(Symbol)
        cls = Types.get_class(arg)
        unless cls
          raise ArgumentError,"invalid class name (#{arg}) specified for java_array"      
        end
        cls_name = arg
        index += 1
      else
        cls = JObject
        cls_name = 'java.lang.Object'
      end
    else
      cls = JObject
      cls_name = 'java.lang.Object'
    end
    cls_name = cls_name.to_sym
    # the (optional) next arg(s) is dimensions. may be
    # specified as dim1,dim2,...,dimn, or [dim1,dim2,...,dimn]
    # the array version is required if you want to pass a
    # fill value after it
    if index < args.length
      arg = args[index]
      if arg.kind_of?(Fixnum)
        dims = [arg]
        index += 1
        while index < args.length && args[index].kind_of?(Fixnum)
          dims << args[index]
          index += 1        
        end
      elsif arg.kind_of?(::Array)
        dims = arg
        index += 1
        fill_value = convert_to_type(cls_name,args[index],block) if index < args.length
      elsif arg.nil?
        dims = ruby_array.dimensions if ruby_array
        index += 1
        fill_value = convert_to_type(cls_name,args[index],block) if index < args.length
      end
    else
      dims = ruby_array.dimensions if ruby_array
    end
    dims = [0] unless dims
    java_array = new_java_array(cls,dims)
    if ruby_array
      ruby_to_java(cls_name,dims,ruby_array,java_array,fill_value,block)          
    elsif fill_value
      ruby_to_java(cls_name,dims,nil,java_array,fill_value,block)
    end
    java_array
  end

  def ruby_to_java(cls_name,dims,ruby_array,java_array,fill_value,block=nil)
    if dims.length > 1
      shift_dims = dims[1...dims.length]
      for i in 0...dims[0]
        if ruby_array.kind_of?(::Array)
          ruby_param = ruby_array[i]
        else
          ruby_param = ruby_array # fill with value when no array        
        end
        ruby_to_java(cls_name,shift_dims,ruby_param,java_array[i],fill_value,block)
      end
    else
      copy_data(cls_name,ruby_array,java_array,fill_value,block)
    end
    java_array 
  end
   
  def convert_to_type(cls_name,val,block= nil)
    return val if val.nil? || val.kind_of?(JavaProxy)
    if block
      block.call(val)
    else
      Types.convert_to_type(cls_name,val)
    end
  end
  
  def copy_data(cls_name,ruby_array,java_array,fill_value,block)
    if ruby_array.kind_of?(::Array)
      rlen = ruby_array.length
    else
      rlen = 0
      # in irregularly-formed Ruby arrays, values that appear where
      # a subarray is expected get propagated. not sure if this is
      # the best behavior, will see what users say
      fill_value = convert_to_type(cls_name,ruby_array,block) if ruby_array    
    end
    jlen = java_array.length
    i = 0
    while i < rlen && i < jlen
      java_array[i] = convert_to_type(cls_name,ruby_array[i],block)
      i += 1
    end
    if fill_value
      while i < jlen
        java_array[i] = fill_value
        i += 1      
      end    
    end
    java_array
  end
  
  # if dimensions is a Fixnum, a single-dimensional Java
  # array will be created with that length. If dimensions
  # is an array, an n-dimensional Java array will be created
  # according to the dimensions specified
  def new_java_array(cls_or_name,dimensions)
    cls = cls_or_name.kind_of?(Class) || 
          cls_or_name.kind_of?(JavaProxy) ? cls_or_name : Types.get_class(cls_or_name)
    if dimensions.kind_of?(Fixnum)
      return JArray.newInstance(cls,dimensions)    
    elsif dimensions.kind_of?(::Array)
      dims = JArray.newInstance(Jint,dimensions.length)
      for i in 0...dimensions.length
        dims[i] = dimensions[i].java_int
      end
      return JArray.newInstance(cls,dims)    
    else
      raise ArgumentError,"Invalid dimensions passed to Arrays::new_java_array"    
    end
  end

  end #self
end #Arrays

class Types
  @classes_mutex = nil
  
  class << self
 
  def get_class(cls_name)
    sym = cls_name.to_sym  # they'll normally be syms already
    cls = nil
    # I tested this vs. using java.util.Hashtable. This was
    # slightly faster (5-10%), but still much slower (250%) than
    # without synchronizing. Oh, well...
    if Cheri.threadsafe
      @classes_mutex ||= Mutex.new
      @classes_mutex.synchronize {
        cls = @classes[sym]
      }
    else
      cls = @classes[sym]
    end
    return nil if cls == :no_class      
    return cls if cls
    begin
      cls = eval(cls_name)
    rescue
      cls = nil
    end
    if Cheri.threadsafe
      @classes_mutex ||= Mutex.new
      @classes_mutex.synchronize {
        @classes[sym] = cls ? cls : :no_class
      }
    else
      @classes[sym] = cls ? cls : :no_class
    end
    cls
  end
  
  def add_class(cls_or_name,sym = nil)
    unless sym.nil? || sym.kind_of?(Symbol)
      raise ArgumentError,"invalid class symbol passed to add_class: #{sym}"
    end
    if cls_or_name.kind_of?(String)
      name = cls_or_name
      cls = get_class(cls_or_name)
      unless cls
        raise ArgumentError,"unresolvable class name passed to add_class: #{cls_or_name}"      
      end
    elsif cls_or_name.kind_of?(Class)
      cls = cls_or_name
      name = cls.kind_of?(JavaProxy) ? cls.java_class.name : cls.name
      # I can't think of why this might happen, but checking anyway...
      unless cls == get_class(name)
        raise ArgumentError,"add_class: conflicting class exists for name: #{name}"      
      end
    else
      raise ArgumentError,"invalid class/classname passed to add_class: #{cls_or_name}"    
    end
    add_class_symbol(sym,cls) if sym
  end

  def add_class_symbol(sym,cls)
    if Cheri.threadsafe
      @classes_mutex ||= Mutex.new
      @classes_mutex.synchronize {
        cached_cls = @classes[sym]
        unless cached_cls == nil || cached_cls == :no_class || cached_cls == cls
          raise ArgumentError,"add_class: symbol #{sym} already defined for class: #{cached_cls}"          
        end
        @classes[sym] = cls unless cls == cached_cls
      }
    else
      cached_cls = @classes[sym]      
      unless cached_cls == nil || cached_cls == :no_class || cached_cls == cls
        raise ArgumentError,"add_class: symbol #{sym} already defined for class: #{cached_cls}"          
      end
      @classes[sym] = cls unless cls == cached_cls
    end    
  end
    
  def convert_to_type(java_cls_name,val)
    return val if val.nil? || val.kind_of?(JavaProxy)
    # TODO: do converters need threadsafe access, now that
    # users can add them?  I think not, since in full Cheri
    # they'll be added in a ContextNode...
    converter = @converters[java_cls_name.to_sym]
    return converter.call(val) if converter
    val
  end

  # used for converting to arrays of java.lang.Object
  def convert_to_best_type(val)
    # some types convert OK in JRuby
#    return val if val.kind_of?(JavaProxy) || val.kind_of?(String) || val.kind_of?(Time)
#      val.kind_of?(TrueClass) || val.kind_of?(FalseClass) || val.nil?
    if val.kind_of?(Numeric)  
      return JInteger.new(val) if Types.does_type_match('int',val)
      return JLong.new(val) if Types.does_type_match('long',val)
      #return JFloat.new(val) if Types.does_type_match('float',val)
      return JDouble.new(val) if Types.does_type_match('double',val)
#      raise 'Arrays::convert_to_best_type can\'t convert value: ' + val.to_s
    end
    val
  end

  # Usage: add_converter cls_or_name [,Proc[,symbol]] | [[,symbol] &block]
  def add_converter(cls_or_name,*args,&block)
    if cls_or_name.kind_of?(String) || cls_or_name.kind_of?(Symbol)
      name = cls_or_name
      cls = get_class(name)
      unless cls
        raise ArgumentError,"unresolvable class name passed to add_converter: #{cls_or_name}"      
      end
    elsif cls_or_name.kind_of?(Class)
      cls = cls_or_name
      name = cls.kind_of?(JavaProxy) ? cls.java_class.name : cls.name
      # I can't think of why this might happen, but checking anyway...
      unless cls == get_class(name)
        raise ArgumentError,"add_converter: conflicting class exists for name: #{name}"      
      end
    else
      raise ArgumentError,"invalid class/classname passed to add_converter: #{cls_or_name}"    
    end
    index = 0
    proc = nil
    sym = nil
    if index < args.length && args[index].kind_of?(Proc)
      proc = args[index]
      index += 1      
    end
    if index < args.length
      if args[index].kind_of?(Symbol) || args[index].kind_of?(String)
        sym = args[index].to_sym
      else
        raise ArgumentError,"invalid argument passed to add_converter: #{args[index]}"    
      end
    end
    unless proc || block
      raise ArgumentError,"no Proc or block passed to add_converter"        
    end
    if proc && block
      raise ArgumentError,"both Proc and block passed to add_converter"            
    end
    proc ||= block
    sym ||= name.to_sym
    if @converters[sym]
      raise ArgumentError,"add_converter: converter symbol already defined: #{sym}"      
    end
    add_class_symbol(sym,cls)
    @converters[sym] = proc
  end

  # type must be a JavaClass
  def type_matches_arg(type,arg)
    return type.assignable_from?(arg.java_class) if arg.kind_of?(JavaProxy)
    if can_match_type(type.name)      
      return does_type_match(type.name,arg)
    else
      # TODO: deal with subclasses of non-final types in TypeMap
      puts 'Warning: Can\'t evaluate type ' + type.name
      return false
    end
  end

  # this should be called first, otherwise the response
  # of does_type_match is ambiguous
  # TODO: deal with subclasses of non-final types 
  def can_match_type(type_cls_name)
    @map[type_cls_name.to_s] != nil
  end
  
  # TODO: deal with subclasses of non-final types 
  def does_type_match(type_cls_name,value)
    rtypes = @map[type_cls_name.to_s]
    return false unless rtypes
    rtypes.each { |rtype|
      if value.kind_of?(rtype[0])
        range = rtype[1]
        if range 
          return value >= range[0] && value <= range[1]        
        else
          return true 
        end
      end
    }
    false    
  end
    
  end  # self

  @map = {
    'boolean' => [[TrueClass, nil],[FalseClass,nil],[NilClass,nil]],
    'byte' => [[Fixnum, [JByte::MIN_VALUE,JByte::MAX_VALUE]]],
    'char' => [[Fixnum, [JCharacter::MIN_VALUE,JCharacter::MAX_VALUE]]],
    'short' => [[Fixnum, [JShort::MIN_VALUE,JShort::MAX_VALUE]]],
    'int' => [[Fixnum, [JInteger::MIN_VALUE,JInteger::MAX_VALUE]]],
    'long' => [[Fixnum, [JLong::MIN_VALUE,JLong::MAX_VALUE]]],
    # the float and double matches are very iffy, as min/max value
    # doesn't tell the whole story... but the way they're actually
    # used should be OK.
    'float' => [[Numeric, [JFloat::MIN_VALUE,JFloat::MAX_VALUE]]],
    'double' => [[Numeric, [JDouble::MIN_VALUE,JDouble::MAX_VALUE]]],

    'java.lang.Boolean' => [[TrueClass, nil],[FalseClass,nil],[NilClass,nil]],
    'java.lang.Byte' => [[Fixnum, [JByte::MIN_VALUE,JByte::MAX_VALUE]],[NilClass,nil]],
    'java.lang.Character' => [[Fixnum, [JCharacter::MIN_VALUE,JCharacter::MAX_VALUE]],[NilClass,nil]],
    'java.lang.Short' => [[Fixnum, [JShort::MIN_VALUE,JShort::MAX_VALUE]],[NilClass,nil]],
    'java.lang.Integer' => [[Fixnum, [JInteger::MIN_VALUE,JInteger::MAX_VALUE]],[NilClass,nil]],
    'java.lang.Long' => [[Fixnum, [JLong::MIN_VALUE,JLong::MAX_VALUE]],[NilClass,nil]],
    'java.lang.Float' => [[Numeric, [JFloat::MIN_VALUE,JFloat::MAX_VALUE]],[NilClass,nil]],
    'java.lang.Double' => [[Numeric, [JDouble::MIN_VALUE,JDouble::MAX_VALUE]],[NilClass,nil]],
    'java.lang.Number' => [[Numeric,nil],[NilClass,nil]],
      
    'java.math.BigInteger' => [[Integer,nil],[NilClass,nil]],
    'java.math.BigDecimal' => [[Numeric,nil],[NilClass,nil]],

    'java.lang.String' => [[String,nil],[NilClass,nil]],
    'java.lang.Object' => [[Object,nil]],
    'java.util.Date' => [[Time,nil],[NilClass,nil]]
  }
  @classes = {
    :boolean => Jboolean,
    :byte => Jbyte,
    :char => Jchar,
    :short => Jshort,
    :int => Jint,
    :long => Jlong,
    :float => Jfloat,
    :double => Jdouble,
    :Boolean => JBoolean,
    SBoolean => JBoolean,
    :Byte => JByte,
    SByte => JByte,
    :Char => JCharacter,
    :Character => JCharacter,
    SCharacter => JCharacter,
    :Short => JShort,
    SShort => JShort,
    :Int => JInteger,
    :Integer => JInteger,
    SInteger => JInteger,
    :Long => JLong,
    SLong => JLong,
    :Float => JFloat,
    SFloat => JFloat,
    :Double => JDouble,
    SDouble => JDouble,
    :object => JObject,
    :Object => JObject,
    SObject => JObject,
    :string => JString,
    :String => JString,
    SString => JString,
    :decimal => JBigDecimal,
    :big_decimal => JBigDecimal,
    :BigDecimal => JBigDecimal,
    SBigDecimal => JBigDecimal,
    :big_int => JBigInteger,
    :big_integer => JBigInteger,
    :BigInteger => JBigInteger,
    SBigInteger => JBigInteger,
  }

  # TODO: add mechanism for adding converters
  # TODO: factor the common procs
  # TODO: smarter conversion based on input type
  @converters = {
    :object => Proc.new {|val| convert_to_best_type(val)},
    :Object => Proc.new {|val| convert_to_best_type(val)},
    SObject => Proc.new {|val| convert_to_best_type(val)},
    :string => Proc.new {|val| val.java_string},
    :String => Proc.new {|val| val.java_string},
    SString => Proc.new {|val| val.java_string},
    # doing conversions this way, rather than using the
    # java_xxx methods, to pick up types other than 
    # Numeric/String that have to_i (or to_f) methods
    # (such as Time).
    :byte => Proc.new {|val| JByte.new(val.to_i)},
    :Byte => Proc.new {|val| JByte.new(val.to_i)},
    SByte => Proc.new {|val| JByte.new(val.to_i)},
    :char => Proc.new {|val| JCharacter.new(val.to_i)},
    :Char => Proc.new {|val| JCharacter.new(val.to_i)},
    :Character => Proc.new {|val| JCharacter.new(val.to_i)},
    SCharacter => Proc.new {|val| JCharacter.new(val.to_i)},
    :short => Proc.new {|val| JShort.new(val.to_i)},
    :Short => Proc.new {|val| JShort.new(val.to_i)},
    SShort => Proc.new {|val| JShort.new(val.to_i)},
    :int => Proc.new {|val| JInteger.new(val.to_i)},
    :Int => Proc.new {|val| JInteger.new(val.to_i)},
    :Integer => Proc.new {|val| JInteger.new(val.to_i)},
    SInteger => Proc.new {|val| JInteger.new(val.to_i)},
    :long => Proc.new {|val| JLong.new(val.to_i)},
    :Long => Proc.new {|val| JLong.new(val.to_i)},
    SLong => Proc.new {|val| JLong.new(val.to_i)},
    :float => Proc.new {|val| JFloat.new(val.to_f)},
    :Float => Proc.new {|val| JFloat.new(val.to_f)},
    SFloat=> Proc.new {|val| JFloat.new(val.to_f)},
    :double => Proc.new {|val| JDouble.new(val.to_f)},
    :Double => Proc.new {|val| JDouble.new(val.to_f)},
    SDouble => Proc.new {|val| JDouble.new(val.to_f)},
    :big_int => Proc.new {|val| JBigInteger.new(val.to_s)},
    :big_integer => Proc.new {|val| JBigInteger.new(val.to_s)},
    SBigInteger => Proc.new {|val| JBigInteger.new(val.to_s)},
    :decimal => Proc.new {|val| JBigDecimal.value_of(val.to_i)},
    :big_decimal => Proc.new {|val| JBigDecimal.value_of(val.to_i)},
    SBigDecimal => Proc.new {|val| JBigDecimal.value_of(val.to_i)},
  }
end #Types

class Util
  class << self
  # upper-case the first char, leaving the rest unchanged
  def upper_first(str)
    new_str = str.to_s
    new_str[0] = new_str[0,1].upcase[0] unless new_str.length == 0
    new_str
  end
  #create upper-camel-case string
  def camel_case(str)
    new_str = str.to_s
    if new_str.index('_')
      new_str.split('_').collect do |s|; upper_first(s); end.join
    else
      # preserve existing camel-case, just force first char to upper
      upper_first(new_str)
    end
  end
  
  alias upper_camel_case camel_case
  
  def lower_camel_case(str)
    # get lower-camel-case method name
    arr = str.to_s.split('_')
    arr.each_index do |i| arr[i].capitalize! if i > 0; end.join
  end

  end #self
end #Util

end #Java
end #Cheri

class Object
  include Cheri::Java::Object
end #Object
class String
  include Cheri::Java::String
end #String
class Numeric
  include Cheri::Java::Numeric
end #Numeric
class Array
  include Cheri::Java::Array
 class << self
  def java_array(*args)
    Cheri::Java::Arrays.java_array(*(args.unshift(nil)))
  end
 end #self
end #Array
