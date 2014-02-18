require "spec_helper"
describe MyMongoid::Document do
 it "is a moule" do 
 	expect(MyMongoid::Document).to be_a(Module)
 end
end