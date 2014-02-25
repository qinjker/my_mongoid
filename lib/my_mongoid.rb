#coding: utf-8
require "my_mongoid/version"
require "my_mongoid/configuration"
require "my_mongoid/error"
require "moped"

module MyMongoid
  def self.models
    @models ||= []
  end
  
  def self.register_model(klass)
    models.push klass if !models.include?(klass)
  end
  
  #定义类的方法configuration
  def self.configuration
    Configuration.instance
  end
  
  #yield 占位符号
  def self.configure
   yield configuration
  end
  
  def self.remove
    remove_instance_variable(:@session) if defined?(@session)
  end
  
  def self.session
    return @session if defined?(@session)
    host = configuration.host
    database = configuration.database
    if host.nil? || database.nil?
      raise UnconfiguredDatabaseError
    end
    @session = Moped::Session.new([host])
    @session.use(database)
    @session
  end
  
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
    @attributes = attrs
    @new_record = true
    process_attributes(attrs)
  end
  
  def to_document
    self.attributes
  end
  
  def process_attributes(attrs)
	  attrs.map do |name,value|
      raise MyMongoid::UnknownAttributeError if !self.respond_to?(name)
      send("#{name}=",value)
    end
  end
  
  #Module的一个私有实例方法，只能用于给方法起别名
  alias_method :attributes=,:process_attributes
	
  #保存方法
  def save
    if self.id.nil?
      self.id = BSON::ObjectId.new
    end
    result = self.class.collection.insert(self.to_document)
    @new_record = false
    true
  end
	
  #判断是不是一个新实例
  def new_record?
    return  @new_record == true
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
  require "active_support/inflector"
  def is_mongoid_model?
    true
  end
	
	def collection
    MyMongoid.session[collection_name]  
  end
  
	def collection_name
    self.to_s.tableize
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
	
	def create(attrs)
   obj = self.new(attrs)
   obj.save
   obj
  end
  
  def instantiate(attrs)
    doc = allocate
    doc.instance_variable_set(:@attributes,attrs)
    doc
  end
  
  def find(query)
    result = self.collection.find(query).one
    if result.nil?
      raise MyMongoid::RecordNotFoundError
    end
    Event.instantiate(result)
  end
	
  def fields
    @fields
  end
end