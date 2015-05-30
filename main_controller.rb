require_relative( 'test_model')
require 'benchmark'
class Main_Controller

  puts Benchmark.bm {
  tester = Test_Model.new()

  tester.run_full_test
       }
end