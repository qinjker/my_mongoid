require "spec_helper"
class Ceshi
	include MyMongoid::Document
	#field :puo
end
describe MyMongoid::Document do
	
  let(:cs) {
    Ceshi.new({"_id" => "123"})
  }
  
  it "is a module" do 
    expect(MyMongoid::Document).to be_a(Module)
  end
  
  it "new mymongoid" do
	  expect(cs).to be_new_record
  end
  
  describe "#read_attribute" do
    it "can be #read_attribute" do
  	  expect(cs.read_attribute("_id")).to eq("123")
  	  #expect(cs.id).to eq("123")	
    end
  end
  
  describe "#write_attribute" do
    it "can be #write_attribute" do
      expect(cs.write_attribute("_id",234)).to eq(234)
    end
  end
  
  describe "#process_attributes" do
    it "can uses #process_attributes for #initialize" do
      cs.process_attributes({"_id"=>"12321"})
      expect(cs._id).to eq("12321")
    end
  end
  
  describe "#new_record?" do
    it "can initialize is new record" do 
      expect(cs).to be_new_record
    end
  end
end