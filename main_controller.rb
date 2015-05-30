require_relative( 'test_model')
require 'benchmark'
class Main_Controller

  puts Benchmark.measure {
  tester = Test_Model.new()

  tester.run_full_test

         puts "\n\n  USER\t\tSYSTEM\t\tTOTAL\t\tREAL"
       }
end