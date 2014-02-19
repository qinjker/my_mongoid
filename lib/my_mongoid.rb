#coding: utf-8
require "my_mongoid/version"

module MyMongoid
	def self.models
		@models ||= []
	end

	def self.register_model(klass)
		models.push klass if !models.include?(klass)
	end
end

class MyMongoid::DuplicateFieldError < RuntimeError
end

class MyMongoid::UnknownAttributeError < RuntimeError
end

module MyMongoid::Document

	def self.included(klass)
		klass.module_eval do
			extend ClassMethods
			field :_id, :as => :id
			MyMongoid.register_model(klass)
		end
	end
	
	#定义一个可以在对象实例中可读的属性
	#类似等于 def attributes
	#	return @attributes
	# end;
	attr_reader :attributes,:new_record
	

	def read_attribute(name)
		@attributes[name]
	end

	def write_attribute(name,value)
		@attributes[name] = value
	end
	
	#定义初始化接收一个hash
	def initialize(attrs={})
		raise ArgumentError unless attrs.is_a?(Hash)
		@attributes = {}#attrs
		@new_record = true
		process_attributes(attrs)
	end

	def process_attributes(attrs)
		attrs.map do |name,value|
			raise MyMongoid::UnknownAttributeError if !self.respond_to?(name)
			send("#{name}=",value)
		end
	end

	#Module的一个私有实例方法，只能用于给方法起别名
	alias_method :attributes=,:process_attributes
	
	#判断是不是一个新实例
	def new_record?
		return @new_record
	end
end

class MyMongoid::Field
	attr_reader :name, :options
	def initialize(name,options)
		@name = name
		@options = options
	end
end

module MyMongoid::Document::ClassMethods

	def is_mongoid_model?
		true
	end
	
	
	def field(name,opts={})
		name = name.to_s
		@fields ||= {}
		raise MyMongoid::DuplicateFieldError if @fields.has_key?(name)
		@fields[name] = MyMongoid::Field.new(name,opts)
		
		self.module_eval do
			define_method(name) do
				read_attribute(name)
			end
			define_method("#{name}=") do |value|
				write_attribute(name,value)
			end
		end
		
		if alias_name = opts[:as]
			alias_name = alias_name.to_s
			self.module_eval do
				alias_method alias_name, name
				alias_method "#{alias_name}=", "#{name}="
			end
		end
		
	end
	
	
	def fields
		@fields
	end
end