module Basic
  def self.say_hello(*, to : String)
    raise ArgumentError.new("Empty message recipient") if to.empty?

    "Hello, #{to}!"
  end
end
