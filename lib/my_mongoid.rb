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

class MyMongoid::Field
end

module MyMongoid::Document
	def self.included(klass)
		klass.module_eval do
			extend ClassMethods
			MyMongoid.register_model(klass)
		end
	end	
end

module MyMongoid::Document::ClassMethods
	def is_mongoid_model?
		true
	end
end