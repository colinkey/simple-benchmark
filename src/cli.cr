require "option_parser"
require "./cli-options"

def handle_cli
  # Set option defaults
  concurrent = false
  iterations = 50
  url = "http://localhost:3000"

  OptionParser.parse do |parser|
    parser.on "-c", "--concurrent", "Perform concurrent benchmark" do
      concurrent = true
    end

    parser.on "-i PASSED_ITERATIONS", "--iterations=PASSED_ITERATIONS", "Specify the number of iterations for a benchmark" do |passed_iterations|
      iterations = Int32.new(passed_iterations)
    end

    parser.on "-u PASSED_URL", "--url=PASSED_URL", "Specify the url to hit for benchmarking" do |passed_url|
      url = passed_url
    end
  end

  CliOptions.new(
    concurrent: concurrent,
    url: url,
    iterations: iterations,
  )
end
