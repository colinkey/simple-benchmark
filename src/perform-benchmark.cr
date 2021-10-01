require "http/client"
require "./cli-options"

METHODS = ["get", "post", "patch", "put", "delete"]

class PerformBenchmark
  @url : String
  @iterations : Int32
  @concurrent : Bool

  def initialize(options : CliOptions)
    @url = options.url
    @iterations = options.iterations
    @concurrent = options.concurrent

    @expected_receipts = 0
    @total_time = 0.0
  end

  def call
    @iterations.times do
      get
      post
      patch
      put
      delete
    end
  end

  def perform
    t1 = Time.utc
    if @concurrent
      call_concurrently
    else
      call
    end
    t2 = Time.utc
    @total_time = (t2 - t1).total_milliseconds
    print_results
  end

  def call_with_receipt(&block)
    spawn do
      block.call
    end
    @expected_receipts += 1
  end

  def call_concurrently
    chan = Channel(Int32).new(10)
    @iterations.times do
      call_with_receipt do
        chan.send(get)
      end
      call_with_receipt do
        chan.send(patch)
      end
      call_with_receipt do
        chan.send(post)
      end
      call_with_receipt do
        chan.send(put)
      end
      call_with_receipt do
        chan.send(delete)
      end
    end
    @expected_receipts.times do
      chan.receive
    end
  end

  macro create_response_handlers
    {% for name in METHODS %}
      def handle_{{ name.id }}_response(response_code : Int32)
        if response_code == 200
          @{{ name.id }}_results["successes"] += 1
        else
          @{{ name.id }}_results["failures"] += 1
        end
      end
    {% end %}
  end

  macro create_verb_methods
    {% for name in METHODS %}
      def {{ name.id }}
        response = HTTP::Client.{{ name.id }} @url
        handle_{{ name.id }}_response response.status_code
      end
    {% end %}
  end

  macro create_result_vars
    {% for name in METHODS %}
      @{{ name.id }}_results = {
        "successes" => 0,
        "failures" => 0,
      }
    {% end %}
  end

  macro create_results_printers
    {% for name in METHODS %}
      def print_{{ name.id }}_results
        puts "{{ name.id.upcase }} request completed #{@iterations} times. Results: Successes #{@{{name.id}}_results["successes"]}, Failures #{@{{name.id}}_results["failures"]}"
      end
    {% end %}

    def print_results
      {% for name in METHODS %}
        print_{{ name.id }}_results
      {% end %}
      puts "Time spent running: #{@total_time}ms"
    end
  end

  create_response_handlers
  create_result_vars
  create_verb_methods
  create_results_printers
end
