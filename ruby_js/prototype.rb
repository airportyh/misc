class Object
  
	def method_missing(m, *args, &block)
	  metaclass = class << self; self; end
		if m[m.size-1] == '=' then
		  prop = m[0..m.size-2]
		  arg = args[0]
		  if Proc == arg.class then
		    metaclass.send(:define_method, prop, &arg)
		  else
		    self.instance_variable_set("@#{prop}", arg)
		    metaclass.send(:attr_accessor, prop)
		  end
		end
	end
end

def constructor sym
  m = method(sym)
  clz = Class.new
  clz.send(:define_method, 'initialize', m)
  clz
end

def User(name)
  self.name = name
end
User = constructor :User




user = Object.new
user.pants = lambda {puts "pants"}
user.pants

user.name = 'Janis'
puts user.name

user.greet = lambda {|other| puts "Hello #{other}"}
user.greet "Bob"

color_name = 'black'
user.color = lambda {
  puts "#{name}'s color is #{color_name}"
}
user.color

user = User.new 'Tom'
puts user.name