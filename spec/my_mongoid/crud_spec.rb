require "spec_helper"

def config_db
  MyMongoid.configure do |x|
    x.host = "127.0.0.1:27017"
    x.database = "my_mongoid_test"
  end
end

class Event
  include MyMongoid::Document
  field :f_1
  field :f_2
end

describe "MyMongid::Configuration" do
  let(:config){
    MyMongoid::Configuration.instance
  }
  
  #验证configuration是不是单例
  it "should be a singleton class" do
    expect(MyMongoid::Configuration.included_modules).to include(Singleton)
  end
  
  #验证MyMongid中有没有host和database读写属性
  it "should have #host accessor and #database accessor" do
    expect(config).to respond_to(:host)
    expect(config).to respond_to(:host=)
    expect(config).to respond_to(:database)
    expect(config).to respond_to(:database=)  
  end
  
end

describe "MyMongoid.configure" do
  it "should yield MyMongoid.configuration to a block" do
    expect{ |x|
      MyMongoid.configure(&x)
    }.to yield_control
    
    MyMongoid.configure do |conf|
      expect(conf).to eq(MyMongoid::configuration)
    end
  end
end

describe "MyMongoid.session" do
  before(:all) {
    config_db
  }
  
  before(:each) {
    # remove memoized session before each test
    #MyMongoid.remove_instance_variable(:@session) if MyMongoid.instance_variable_defined?(:@session) ruby 1.9不支持类调用 是私有方法
    MyMongoid.remove if MyMongoid.instance_variable_defined?(:@session)
  }
  
  it  "should return a Moped::Session" do
   expect(MyMongoid.session).to be_a(Moped::Session)
  end
  
  it "should memoize the session @session" do
    expect(MyMongoid.session).to eq(MyMongoid.instance_variable_get(:@session))
  end
  
  it "should raise MyMongoid::UnconfiguredDatabaseError if host and database are not configured" do
    config = MyMongoid.configuration
    config.host = nil
    config.database = nil
    expect{
      MyMongoid.session
    }.to raise_error(MyMongoid::UnconfiguredDatabaseError)
  end
end

describe ".configuration" do
  it "should return the MyMongoid::Configuration singleton" do
    expect(MyMongoid.configuration).to be_a(MyMongoid::Configuration)
    expect(MyMongoid.configuration).to eq(MyMongoid::Configuration.instance)
  end
end