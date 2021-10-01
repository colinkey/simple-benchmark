require "./cli"
require "./perform-benchmark"

opts = handle_cli

benchmarker = PerformBenchmark.new(opts)
benchmarker.perform

