## Required Gems


class Build_Model


    ## Attr Accessors

    attr_reader :category_names, :category_prob_hashes, :category_overall_probability, :overall_word_probability

    ## Class Variables

    # For Lenovo
    @@raw_data_directory_name = '/home/christopher/Documents/Programs/WMU_Assignments/CS5950-Machine_Learning/1.Classification/Data/20news-bydate-train'
    @@processed_data_directory_name = '/home/christopher/Documents/Programs/WMU_Assignments/CS5950-Machine_Learning/1.Classification/Processed_Data'


    # For Mac
    # @@raw_data_directory_name = '/Users/christopher/Documents/WMU_Classes/CS5950/CS5950-Machine_Learning/1.NewsGroups/Data/20news-bydate-train'
    # @@processed_data_directory_name = '/Users/christopher/Documents/WMU_Classes/CS5950/CS5950-Machine_Learning/1.NewsGroups/Processed_Data'

    ## Instance Variables
    @category_names
    @category_files
    @category_prob_hashes
    @category_freq_hashes
    @category_overall_prob
    @overall_word_probability
    @overall_word_freq

    ## Methods/Functions

    def initialize
      instantiate_directories_and_files
      build_category_hash_models
      build_overall_probability_hash
      build_overall_word_probability_list

    end


    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    def instantiate_directories_and_files

      @category_names = []
      @category_files = []

      processed_data_dir
      raw_data_dir

      @processed_data_dir.each_entry do |entry|
        unless entry == '.' || entry == '..'
          @category_files << "#{entry.to_s}"
          @category_names << "#{entry.to_s.sub!('.csv', '')}"
        end
      end
    end



    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------

    def build_category_hash_models

      @category_prob_hashes = Hash.new()
      @category_freq_hashes = Hash.new()


      category_names.each do |name|
        @category_prob_hashes[name.to_sym] = Hash.new()
        @category_freq_hashes[name.to_sym] = Hash.new()
        temp = File.new("#{@@processed_data_directory_name}/#{name}.csv", 'r')
        count = Integer(0)

        temp.each_line do |line|
          unless count == 0
            words = line.split(',')
            @category_freq_hashes[name.to_sym][words[0].to_sym] = words[1].sub("\n", '').to_i
          end
          count += 1
        end

        #50.times {print "-"}
        #puts "\nShowing #{file_name}\n"
        #50.times {print "-"}
        #print "\n"
        #puts @category_hashes[file_name].to_s
      end

      @category_freq_hashes.each_key  do |key|
        total = Float(0.0)
        total += @category_freq_hashes[key][:"%total_words"]

        @category_freq_hashes[key].each do |key2, value2|
          @category_prob_hashes[key][key2] = value2/total
        end
        # 50.times {print "-"}
        # puts "\nFor #{key}: \n"
        # puts @category_hashes[key].to_a
      end

    end

    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------


    def build_overall_probability_hash

      @category_overall_prob = Hash.new()
      @total_files = Float(0)

      @category_names.each do |file|

          temp_dir = Dir.new("#{@@raw_data_directory_name}/#{file.to_s}")
          count = Integer(-2)
          temp_dir.each_entry do
            count += 1

          @category_overall_prob[file] = count
          @total_files += count
        end
      end



    end

    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------

    # Create Probability Lists for each word taken as a group (Without Categories)

    def build_overall_word_probability_list
      @overall_word_freq = Hash.new()
      @overall_word_probability = Hash.new()
      @category_names.each do |name|
        @category_prob_hashes[name.to_sym].each do |key, value|
          if( @overall_word_freq.has_key?( key ))
            @overall_word_freq[key] += value
          else
            @overall_word_freq[key] = value
          end
        end
      end

      total_words = @overall_word_freq.values.reduce(0) {|sum, value| sum + value}

      @overall_word_freq.each do |key, value|
        @overall_word_probability[key] = value/total_words
      end


    end








    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------





    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------



    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------
    #  ---------------------------------------------------------------------------------------------------------------------


private

    def processed_data_dir
      @processed_data_dir ||= Dir.new @@processed_data_directory_name
    end
    def raw_data_dir
      @raw_data_dir ||= Dir.new @@raw_data_directory_name
    end

end
