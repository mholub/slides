%w[colorize pp].each { |g| require g }

TEXT = nil
CODE = "> ".green
OUT = "> "
ERR = "! ".red

#TODO make delayed output
def p(s, del=TEXT)
	s.split("\n").each { |l| puts [del, l].compact.join(' ') }	
end

def pe(code)
	p code, CODE
	begin
		p eval(code).inspect, OUT
	rescue => e
		p ERR + " " + e.inspect
	end
end

class Presentation
	attr_reader :slides

	def play
		@slides.each do |s|
			send s
		end
	end

	def header slide_name
		puts "#{@slides.index(slide_name)+1}/#{@slides.length} #{slide_name}".yellow 
	end

	def slide slide_name
		@slides << slide_name
		class << self; self; end.instance_eval do
			define_method(slide_name) do 
				header slide_name
				yield
				puts "\n"
			end
		end
	end

	def initialize &block
		@current_slide = 0
		@slides = []
		instance_eval &block
	end

	def n
		send @slides[@current_slide]
		@current_slide += 1
	end
end

def n
	$p.n
end

$p = Presentation.new do |p|
	slide :goals do
		p "Are:"
		p "to show interesting ruby features"
		p "to improve bookmate's team understanding of ruby magic"
		gets
		p "Are not:"
		p "to teach you ruby (go and grab Pickaxe: http://pragprog.com/book/ruby/programming-ruby)"
		p "to give you deep understanding of how ruby works"
		gets
		p "We may have series of deep ruby lectures in the future"
	end

	slide :target_audience do
		p "I expect basic understanding of ruby"
		p "I will not explain every part of ruby"
		p "Ask me if anything is not clear"
		gets
	end

	slide :plan do
		p "1. Random chunks of ruby"
		p "2. Ruby metaprogramming"
		p "3. Where to find docs"
		p "4. Questions"
		gets
		p "No rails today, sorry"
		gets
	end

	slide :symbols do
		p ":something means symbol"
		pe ":something.class"
		gets
		p "symbols are unique strings (stored as integers in global hashmap)"
		p "used as entity names like methods, classes, database columns, hash keys, etc\n"
		gets
		p "you can use String#intern method to convert String to symbol"
		pe "'I am some string'.intern"
		gets
	end
	slide :variable_scopes do
		p "Ruby has global, local, instance and class variables"
		gets
		p "$something means global variable with name something"
		pe "$something = 5"
		gets
		p "@something means instance variable with name something"
		gets
		p "@@something means class variable with name something"
		gets
		pe <<-RUBY_CODE
class IamAClass
	@@number_of_instances = 0
	def initialize
		@@number_of_instances += 1
		@something = "instance variable"
	end

	def self.number_of_instances
		@@number_of_instances
	end

	def foo
		@something
	end
end
		RUBY_CODE
		gets
		pe "IamAClass.number_of_instances"
		gets
		pe "10.times { IamAClass.new }"
		gets
		pe "IamAClass.number_of_instances"
		gets
		p "something is local variable or sending message (method call)"
		gets
		pe "something = 4"
		gets
		pe "something_unknown"
		gets
		p "self.something is always message send"
		gets 
		p "no variable access like in C++/Java"
		gets
		p "use attr_reader, attr_accessor to define getters/setters for instance vars"
		gets
		pe <<-RUBY_CODE
class ClassWithVar
	attr_accessor :property
	def initialize
		@property = 5
	end
end
ClassWithVar.new.property
		RUBY_CODE
		gets
	end

	slide :everything_is_object do
		p "OOP, everything is object (like in Smalltalk, IO, Self)\n"
		pe %Q{2.is_a? Object}
		gets
		pe %Q{true.is_a? Object}
		gets
		pe %Q{lambda {|x| x + 3}.is_a? Object}
		gets 
		p "Even classes are objects"
		pe %Q{String.is_a? Object}
		gets
		pe %Q{Class.is_a? Object}
		gets
		pe %Q{Object.is_a? Object}
		gets
	end

	slide :every_syntax_structure_has_value do 
		p "Like in Coffeescript (better to say that in Coffeescript like in Ruby)"
		gets
		p "conditional statement"
		pe <<-RUBY_CODE
value = if true
	"inside if branch"
else
	"inside else branch"
end
		RUBY_CODE
		gets
		p "loops"
		pe <<-RUBY_CODE
value = while true
	break "inside while loop"
end
	RUBY_CODE
		gets
		p "Even those you don't expect: class definition"
		pe <<-RUBY_CODE
local_variable_pointing_to_class = class SomeNewClass
	self
end
		RUBY_CODE
		gets
	end

	slide :everything_is_dynamic do 
		p "How about extending random class?"
		pe <<-RUBY_CODE
class VeryStrangeSubclass < [Hash, String, Fixnum, Array, Time][rand(5)]
	self
end.superclass
		RUBY_CODE
		gets
	end

	slide :sending_messages_instead_of_calling_methods do
		p "All method calls are dynamic\nThat is why ruby is so slow\nAnd that is why it is so powerful"
		gets
		pe "Ruby.is.not.magic # should raise error"
		gets

		class String
			alias :old_method_missing :method_missing
		end

		pe <<-RUBY_CODE
def Object.const_missing name
	name.to_s
end

class String
	def method_missing meth, *args, &block
		self + " " + meth.to_s
	end
end
		RUBY_CODE
		gets
		pe "Ruby.is.not.magic # should print string"
		class String
			alias :method_missing :old_method_missing
		end
		p "The simplest internal DSL for composing strings"
		gets
		p "You can send message with send method"
		gets
		pe <<-RUBY_CODE
method = [:to_s, :to_f][rand(2)]
2.send(method)
		RUBY_CODE
		gets
	end

	slide :open_classes do
		p "Every ruby class is open"
		p "It means you can add/change methods in runtime in any way like in JS"
		gets
		pe <<-RUBY_CODE
class Fixnum
	def hours
		self * 3600
	end
	def minutes
		self * 60
	end
end
10.hours + 30.minutes
		RUBY_CODE
		gets
	end

	slide :aliased_too do
		p "Alias original method to use it in implementation"
		gets
		pe <<-RUBY_CODE
class Fixnum
	alias :orig_plus :+
	def +(other)
		self.orig_plus(other).orig_plus(1)
	end
end
2 + 2
		RUBY_CODE
class Fixnum
	def +(other)
		self.orig_plus(other)
	end
end
		gets
	end
	slide :why_ruby_has_so_many_strange_keywords do
		p "like attr_reader, cattr_accessor, has_one, has_many, etc, etc, etc"
		gets
		p "it doesn't"
		gets
		p(<<-TEXT
class Vkontakte
	cattr_accessor :api_key
end		

How it works? 
			TEXT
			)
		gets
		p "Every ruby code is executed code"
		gets
		p(<<-TEXT
class Vkontakte
	<code>
end		

means change self to Vkontakte and eval <code> inside this context
similar how function invocation changes 'this' pointer in Javascript
			TEXT
			)
		gets
		p "cattr_accessor :api_key is simple method call"
		gets
		p "But where is it defined?"
		gets
		p "It is defined as instance method of class Class because Vkontakte.is_a? Class"
		gets
	end
	slide :prototypes_aka_metaclasses_aka_eigenclasses do
		p "Every ruby object has its own singleton class aka eigenclass"
		gets
		p "It is similar to prototype in Javascript"
		gets
		pe <<-RUBY_CODE
$not_empty_array = []
def $not_empty_array.empty?
	false
end
$not_empty_array.empty?
		RUBY_CODE
		gets
		pe "[].empty?"
		gets
		p "Another way to write this"
		pe <<-RUBY_CODE
$not_empty_array = []
class << $not_empty_array
	def empty?
		false
	end
end
$not_empty_array.empty?
		RUBY_CODE
		gets
		pe "[].empty?"
		gets
		p "$not_empty_array has its own class, but Ruby hides it from you"
		pe "$not_empty_array.class"
		gets
		p "You can get it with simple trick"
		pe <<-RUBY_CODE
$metaclass = class << $not_empty_array
	self
end
	RUBY_CODE
	p "You can use it as any other ruby object"
	pe <<-RUBY_CODE
$metaclass.class_eval do
	def fill_me_with_random_numbers
		10.times { self << rand(10) }
		self
	end
end
$not_empty_array.fill_me_with_random_numbers
	RUBY_CODE
	end
	slide :class_eval_vs_instance_eval do
		p "instance_eval is method of class Object"
		gets
		p "so it is defined for all Objects"
		p "it changes self to particular object and evals code inside"
		p "same as class << object; end"
		pe <<-RUBY_CODE
class MyFunnyClass; end
MyFunnyClass.instance_eval do
	def class_method
		"hello"
	end
end
MyFunnyClass.class_method
		RUBY_CODE
		gets
		p "class_eval is method of class Module"
		gets
		p "so it is available only for classes and modules"
		gets
		p "same as class Class; end"
		pe <<-RUBY_CODE
class MyFunnyClass; end
MyFunnyClass.class_eval do
	def instance_method
		"hello"
	end
end
MyFunnyClass.new.instance_method
		RUBY_CODE
	end
	slide :modules do
		p "Modules are Ruby's answer to multiple inheritance"
		gets 
		p "You can extend only one class but include as many as you wish modules"
		gets
		p "Modules can't be instantiated"
		gets
		p "Modules can't have instance variables"
		gets
		p "You can include module"
		pe <<-RUBY_CODE
module FooBarable
	def foo
		"foo"
	end
	def bar
		"bar"
	end
end
class IWantToBeFooBarable
	include FooBarable
end
IWantToBeFooBarable.new.foo
		RUBY_CODE
		gets	
		p "Or you can extend module"
		pe <<-RUBY_CODE
class IWantToBeFooBarable
	extend FooBarable
end
IWantToBeFooBarable.bar
		RUBY_CODE
		gets
		p "Modules have Module::included callback"
		pe <<-RUBY_CODE
module TracksHisUsage
	def self.included(klass)
		puts self.to_s + " included in " + klass.to_s
	end
end
class ClassUsingModule
	include TracksHisUsage
end
		RUBY_CODE
	end
	slide :example_of_magic do
		p "Let implement our own special method magic"
		gets
		pe <<-RUBY_CODE
module UselessMagic
	def random_method
		words = open("/usr/share/dict/words").read.split
		word = words[rand(words.size)]
		define_method(word) { puts word }
	end
end
class MyNewShinyClassWithMagic
	extend UselessMagic
	random_method
	random_method
	random_method
end
		RUBY_CODE
		gets
		pe "MyNewShinyClassWithMagic.instance_methods"
	end
	slide :where_to_go_next do
		p "Third part of Pickaxe book contains deep explanation of metaprogramming in Ruby"
		gets
	end
	slide :irb do
		p "irb (interactive ruby) is your friend"
		gets
		p "useful things:"
		pe "1.methods.sort"
		gets
		pe "require 'pp'; pp ENV; nil"
		gets
	end
	slide :where_is_method_defined do
		p "How can I say where is method defined?"
		gets
		p "Use method(:symbol).source_location"
		p "Works only on 1.9+"
		gets
		pe "2.method(:+).source_location"
		p "it was defined in runtime using Kernel#eval\n "
		gets
		pe "Presentation.instance_method(:n).source_location"
		gets
    p "Examples from bookmate"
		gets
		p "irb(main):008:0> Book.method(:define_index).source_location"
		p '=> ["/usr/local/opt/rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/thinking-sphinx-2.0.10/lib/thinking_sphinx/active_record.rb", 157]'
		gets
    p 'irb(main):009:0> Book.method(:cattr_accessor).source_location'
		p '=> ["/usr/local/opt/rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/activesupport-3.1.1/lib/active_support/core_ext/class/attribute_accessors.rb", 75]'
		gets
		p 'irb(main):010:0> Book.method(:has_uuid).source_location'
		p '=> ["/Users/mholub/projects/bookmate/bookmate/vendor/plugins/has_uuid/lib/has_uuid.rb", 7]'
		gets
	end
	slide :where_to_find_documentation do
		p "ri - is console interface to rubydoc"
		p "ri String#+", CODE
		puts `ri String#+`
		gets
		p "gem server - documentation and gem repository HTTP server"
		gets
		p "http://ruby-doc.org/ - online documentation on core and stdlib"
		gets
	end
	slide :questions do
		p "Any?"
		gets
		p "Thanks"
	end
end