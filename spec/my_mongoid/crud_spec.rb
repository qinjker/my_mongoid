require "spec_helper"

# def config_db
#   MyMongoid.config do |config|
#     config.host = "127.0.0.1:27017"
#     config.database = "my_mongoid_test"
#   end
# end

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

describe ".configuration" do
  it "should return the MyMongoid::Configuration singleton" do
    expect(MyMongoid.configuration).to be_a(MyMongoid::Configuration)
    expect(MyMongoid.configuration).to eq(MyMongoid::Configuration.instance)
  end
end