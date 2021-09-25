require "./perform-benchmark"

benchmarker = PerformBenchmark.new("http://localhost:3000")
benchmarker.perform
