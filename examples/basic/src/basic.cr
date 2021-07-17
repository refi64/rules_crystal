require "./basic/hello"

module Basic
  def self.main
    puts self.say_hello(to: "World")
  end
end

Basic.main
