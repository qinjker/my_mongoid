#coding: utf-8
require "my_mongoid/version"

module MyMongoid

end
	
#def MyMongoid::Document
module MyMongoid::Document

end

#def MyMongoid::Document::ClassMethods
module MyMongoid::Document::ClassMethods
	#定义is_mongoid_model?方法
	def is_mongoid_model?
		true
	end
end
