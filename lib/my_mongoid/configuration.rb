module MyMongoid
  require "singleton"
  class  Configuration
    include Singleton
    attr_accessor :host
    attr_accessor :database
  end
end