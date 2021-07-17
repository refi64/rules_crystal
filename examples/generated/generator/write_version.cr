require "option_parser"

module WriteVersion
  def self.main
    if ARGV.size != 3
      STDERR.puts "Invalid number of arguments"
      exit 1
    end

    output = ARGV[0]
    name = ARGV[1]
    version = ARGV[2]

    File.write(output, <<-EOF
      module #{name}
        VERSION = "#{version}"
      end
    EOF
    )
  end
end

WriteVersion.main
