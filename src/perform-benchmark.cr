require "http/client"

METHODS = ["get", "post", "patch", "put", "delete"]

class PerformBenchmark
  def initialize(url : String, iterations = 50)
    @url = url
    @iterations = iterations
  end

  def perform
    @iterations.times do
      get
      post
      patch
      put
      delete
    end

    # METHODS.each do |verb|
    #   @iterations.times do
    #     verb
    #   end
    # end

    print_results
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
    end
  end

  create_response_handlers
  create_result_vars
  create_verb_methods
  create_results_printers
end
