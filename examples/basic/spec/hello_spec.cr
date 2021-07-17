require "./spec_helper"
require "../src/basic/hello"

describe Basic do
  it "says hello to the correct person" do
    Basic.say_hello(to: "Human").should eq("Hello, Human!")
  end
end
