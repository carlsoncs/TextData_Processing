

## Required Gems

require( 'rubygems' )
require( 'lingua/stemmer' )
require( 'benchmark' )


class PreProcessData


  ## Constant Variables

  stopwords_file_name = '/Users/christopher/RubymineProjects/Pre-Process_Text_Data/Word_Count_Files/stopwords.txt'
  destination_directory_name = '/Users/christopher/Documents/WMU_Classes/CS5950/CS5950-Machine_Learning/1.NewsGroups/Pre-Processed_Data'
  ## Methods/Functions

  def self.get_base_dir
    good_file = false
    good_directory = false
    until good_directory
      until good_file
        puts "Enter the Full Path to the Directory to be processed"
        dirName = String.new('')
        dirName = gets()

        dirName.strip!()
        dirName.sub!("\n", '')

        if File.exist?(dirName)
          good_file = true
        else
          puts 'This file does not exist.'
        end
      end

      if File.directory?(dirName)
        good_directory = true
      else
        puts 'This is not a directory.'
      end
    end
    dirName
  end


#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------

  ## Quick Function to populate an array with the current stopwords list.
  def self.populate_stopwords_array(stopwords_file_name)
    stopwords_file = File.new(stopwords_file_name, 'r')
    stopwords_array = []
    stopwords_file.each_line() do |line|
      stopwords_array << line
    end
    stopwords_array
  end




#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------

  ## Returns an array of words with stopwords removed.

  def self.strip_stopwords(words='NA', stopwords_array = [])
    good_words = []
    unless words=='NA'|| stopwords_array.empty?
      words.sub!('\n', '')
      good_words = words.split.delete_if{|x| stopwords_array.include?(x)}

    end
    good_words
  end


#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------

  ## returns word stem for any word given, also rejects words with numbers or non-standard punctuation
  ## in them by simply returning the string 'NA'.
  def self.stem_word(word='NA')
    unless word == 'NA'
      word = Lingua.stemmer(word)
    end
  end



#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------


  ## Returns a has with the form "word":n_occurences, it takes a subdirectory name which holds
  ## some large number of pre-categorized files in it.  It parses the files, removes all the
  ## stopwords, stems the words, and then adds them to the hash or increments the n_occurrances
  ## to the desired levels.

  def self.build_words_hash(cat_dir, stopwords_array,  log = File.new('log.txt', 'w+'))

      words_hash = Hash.new()
      Dir.chdir cat_dir
      puts "Beginning Traversal of #{Dir.pwd} files."


      progress_counter = Integer(0)

      cat_dir.entries.each do |file|
        progress_counter += 1

        unless File.directory? file

          File.open(file, 'r') do |tmp_file|
            #print "Opened #{file}."
            #log.write("Opened #{file}.")

            tmp_file.each_line do |line|

              line = line.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => '')
              line.strip!
              line.sub!("\n", '')
              line.downcase!
              line.gsub!(/\A\p{Alnum}+\z/i, '')

              words = strip_stopwords(line, stopwords_array)


              words.each do |word|
                unless word.length < 3 || word !~ /\A\p{Alnum}+\z/ || word.length > 20
                  word = stem_word(word)

                  if words_hash.has_key?(word)
                    words_hash[word] += 1
                  else
                    words_hash[word] = 1
                  end
                end
              end
            end
            tmp_file.close
          end

          if(progress_counter % 200 == 0 && progress_counter != 0)
            puts "Progress on #{cat_dir.path}: #{progress_counter} files processed.\n\t--signed, #{Process.pid}\n"
          end
        end
      end

      puts "Completed Processing of #{cat_dir.path}.  #{progress_counter} files processed.\n\t--signed, #{Process.pid}\n"
      words_hash = words_hash.sort_by() {|key, value| value}.reverse!
      return words_hash

  end

#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------


  ## Write the words hash to a .csv file

  def self.write_words_hash_to_file(words_hash = Hash.new(), file_name = '', destination_directory = nil, stopwords_array, log )


    if destination_directory.nil?
      return nil
    end
      Dir.chdir(destination_directory)

      new_file = File.new("#{file_name}.csv", "w+")

      puts "Created File named #{file_name}.csv.\n\t--Signed by Process: #{Process.pid}.\n"
      log.write("Created File named #{file_name}.csv. \n\t--Signed by Process: #{Process.pid}.\n")


      new_file.write("Word, Frequency\n")

      sums = Float(0)

      words_hash.each do |key, value|
        if key.to_s =~ /\d/ || stopwords_array.include?(key)
          next
        end
        new_file.write("#{key}, #{value}\n")
        sums += value
      end

      new_file.write("%total_words, #{sums}")

      new_file.close
      log.write("Finished writing #{file_name}.csv. \n\t--Signed by Process: #{Process.pid}.\n")
  end



#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------


  def self.write_all_words_file(base_dir_name = '', log = File.new('log.txt', 'w+'))
    puts "This Method isn't working yet."
  end

#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------
#  ---------------------------------------------------------------------------------------------------------------------


  #####         Main Logic          #####

  start_time = Time.now()

  stopwords_array = populate_stopwords_array(stopwords_file_name)

  puts stopwords_array

  Dir.chdir('/Users/christopher/Documents/Programs/RandomJunk/WordData')
  # Change Directory to the place where you want the csv files placed.
  log = File.new('log.txt', 'w+')

  log.write("Program Run at #{Time.now}.\n")


  dirName = get_base_dir

  log.write "Base Directory Specified as #{dirName}.\n"


  this_dir = Dir.open(dirName)

  Dir.chdir dirName
  log.write "Changed working Directory to #{Dir.getwd}.\n"

  this_dir.entries.each do |entry|

    unless entry == '.' || entry == '..' || entry.include?(".csv")
      fork do
        temp_dir = Dir.open(entry)
        words_hash = build_words_hash(temp_dir, stopwords_array, log)

        unless words_hash.nil?
          write_words_hash_to_file(words_hash, entry, destination_directory_name, stopwords_array, log)
        end
      end
    end
  end

  Process.waitall

  end_time = Time.now()

  total_time = end_time - start_time

  log.write "Closing Log File.\n"
  log.write "Total run time was #{total_time} seconds or #{total_time/60.0} minutes."
  log.close

  puts "Total run time was #{total_time} seconds or #{total_time/60.0} minutes."
end









