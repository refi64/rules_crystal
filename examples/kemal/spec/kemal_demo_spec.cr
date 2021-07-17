require "./spec_helper"
require "../src/kemal_demo/routes.cr"

describe "KemalDemo" do
  it "renders /" do
    get "/"
    response.body.should eq "Hello, Kemal!"
  end
end
