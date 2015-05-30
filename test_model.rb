require_relative( 'build_model' )
require( 'lingua/stemmer' )


class Test_Model

  ## Class Variables

  # For Lenovo
  @@test_data_location = '/home/christopher/Documents/Programs/WMU_Assignments/CS5950-Machine_Learning/1.Classification/Data/20news-bydate-test'
  @@results_file_location = '/home/christopher/Documents/Programs/WMU_Assignments/CS5950-Machine_Learning/1.Classification'


  # # For Mac
  # @@test_data_location = '/Users/christopher/Documents/WMU_Classes/CS5950/CS5950-Machine_Learning/1.NewsGroups/Data/20news-bydate-Test'
  # @@results_file_location = '/Users/christopher/Documents/WMU_Classes/CS5950/CS5950-Machine_Learning/1.NewsGroups'
  #


  def initialize
    @model = Build_Model.new()
    locate_and_load_test_data
    initialize_results_file

  end

  def locate_and_load_test_data
    @test_data_dir = Dir.new(@@test_data_location)
    @total_files = Dir.glob(File.join(@test_data_dir, '**', '*')).select { |file| File.file?(file) }.count

    @test_data_subdirs = []

    @test_data_dir.each_entry do |subdir|
      @test_data_subdirs << Dir.new("#{@test_data_dir.path}/#{subdir}")
    end

  end

  def initialize_results_file
    Dir.chdir(@@results_file_location)

    @results_file = File.new("results.txt", 'w+')

  end

  def stem_word(word='NA')
    unless word == 'NA'
      word = Lingua.stemmer(word)
    end
  end


  def categorize_file(file_path)

    unless File.directory?(file_path) || !File.exist?(file_path)
      temp_file = File.new(file_path, 'r')
      all_words = Hash.new()
      probabilities_hash = Hash.new()

      category_names = @model.instance_variable_get(:@category_names)

      category_words_hash = @model.instance_variable_get(:@category_hashes)

      overall_category_prob = @model.instance_variable_get(:@category_overall_prob)
      total_category_files = Float(0)
      total_category_files += overall_category_prob.each_value.inject(0) {|result, value| result + value}
      overall_category_prob.each {|key,value| overall_category_prob[key] = value/total_category_files}

      overall_word_prob = @model.instance_variable_get(:@overall_word_probability)



      temp_file.each_line do |line|
        line = line.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => '')
        line.strip!()
        line.sub("\n", '')
        words = line.split()
        words.each {|word| word.downcase!}
        words.each {|word| word.sub!(/[\d]+/, '')}
        words.each {|word| word.sub!(/[^\w]+/, '')}
        words.each do |word|

          word = stem_word(word)

          if all_words.has_key?(word)
            all_words[word] += 1
          else
            all_words[word] = 1
          end

        end
      end

      ## Here is where the "math" takes place.
      category_names.each do |name|
        tprob = Float(1.0)
        category_hash = category_words_hash[name.to_sym]
        all_words.each do |key, value|
          if category_hash.has_key?(key.to_sym)
            tprob *= (value +1)
            tprob /= ( 1+ overall_word_prob[key.to_sym])
            tprob *= (overall_category_prob[name] +1)
          end
        end

        probabilities_hash[name] =  tprob

      end

      probabilities_hash = probabilities_hash.sort_by() {|key, value| value}.reverse!.to_h


      probabilities_hash.keys[0]


    end

  end


  def run_full_test

    confusion_matrix_hash = Hash.new()
    category_names = @model.instance_variable_get(:@category_names)

    category_names.each do |name|
      confusion_matrix_hash[name] = Hash.new()
    end
    category_names.each do |row_name|
      category_names.each do |col_name|
        confusion_matrix_hash[row_name][col_name] = Integer(0)
      end
    end

    print_progress_bar

  counter = Integer(0)  # Used to track overall progress.
  @test_data_subdirs.each do |subdir|

    unless File.basename(subdir.path).to_s == '.' || File.basename(subdir.path).to_s == '..'
      subdir.each_entry do |entry|
        unless File.directory?(entry)

          counter += 1
          if(counter % (@total_files/101) == 0)
            print "."
          end

          category = categorize_file("#{subdir.path}/#{entry}")

          # @results_file.write("For file #{entry} in #{File.basename(subdir.path)} categorized as:  #{category}\n")

          confusion_matrix_hash[File.basename(subdir.path)][category] += 1

        end
      end

    end

  end
    print ">\n"
    @results_file.write " , "
    confusion_matrix_hash.each_key {|key| @results_file.write("#{key}, ")}
    @results_file.write("\n")
  confusion_matrix_hash.each do |key, value|
    @results_file.write( "#{key}, " )
    value.each do |key2, value2|
      @results_file.write "#{value2}, "
    end
    @results_file.write("\n\n\n")
  end
  @results_file.close

    total_processed = Float(0)
    total_correct = Float(0)
    total_incorrect = Float(0)

    confusion_matrix_hash.each_key do |key|
      confusion_matrix_hash[key].each {|key2,value| total_processed += value}
    end
    confusion_matrix_hash.each_key do |key|
      total_correct += confusion_matrix_hash[key][key]
    end

    total_incorrect = total_processed - total_correct

    puts "Total: #{total_processed}\nTotal Correct: #{total_correct}\nTotal Incorrect: #{total_incorrect}\nPercent Correct: #{total_correct/total_processed}"

  end



  private

  def print_progress_bar
    print "Progress: <0%"
    21.times {print " "}
    print "25%"
    22.times {print " "}
    print "50%"
    22.times {print " "}
    print "75%"
    21.times {print " "}
    print "100%>\n"
    print "Progress: <"
  end

end
