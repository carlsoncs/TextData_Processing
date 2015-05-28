require_relative( 'build_model' )

class Test_Model

  ## Class Variables
  @@test_data_location = '/home/christopher/Documents/Programs/WMU_Assignments/CS5950-Machine_Learning/1.Classification/Data/20news-bydate-test'
  @@results_file_location = '/home/christopher/Documents/Programs/WMU_Assignments/CS5950-Machine_Learning/1.Classification'




  def initialize
    @model = Build_Model.new()
    locate_and_load_test_data
    initialize_results_file
    @results_file.write( "Initialization of Test complete.  Beginning Tests.\n")
  end

  def locate_and_load_test_data
    @test_data_dir = Dir.new(@@test_data_location)
    @test_data_subdirs = []

    @test_data_dir.each_entry do |subdir|
      @test_data_subdirs << Dir.new("#{@test_data_dir.path}/#{subdir}")
    end

  end

  def initialize_results_file
    Dir.chdir(@@results_file_location)

    @results_file = File.new("results.txt", 'w+')

    puts @results_file.path
  end

  Test_Model.new

end