require "./perform-benchmark"

benchmarker = PerformBenchmark.new("http://127.0.0.1:3000", 200)
benchmarker.perform_concurrent

