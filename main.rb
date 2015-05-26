class Main


  Dir.chdir('/Users/christopher/Documents/Programs/RandomJunk/WordData')
  # Change Directory to the place where you want the csv files placed.
  log = File.new('log.txt', 'w+')

  log.write("Program Run at #{Time.now}.\n")
  all_words = Hash.new()
  good_directory = false
  until good_directory
    puts "Enter the Full Path to the Directory to be processed"
    dirName = String.new('')
    dirName = gets()

    dirName.strip!()
    dirName.sub!("\n", '')

    if File.exist?(dirName)
      good_directory = true
    else
      puts 'This directory does not exist.'
    end
  end

  log.write "Base Directory Specified as #{dirName}.\n"
  this_dir = Dir.open(dirName)

  Dir.chdir dirName
  log.write "Changed working Directory to #{Dir.getwd}.\n"

  this_dir.entries.each do |entry|

    words_hash = Hash.new()

    unless entry == '.' || entry == '..' || entry.include?(".csv")

      new_file = File.new("#{entry}.csv", "w+")
      puts "Created File named #{entry}.csv."
      log.write("Created File named #{entry}.csv.\n")

      cat_dir = Dir.open(entry)
      Dir.chdir entry
      puts "Beginning Traversal of #{entry} files."

      cat_dir.entries.each do |file|

        unless File.directory? file

          File.open(file, 'r') do |tmp_file|
          print "Opened #{file}."
          log.write("Opened #{file}.")

           tmp_file.each_line do |line|

              line = line.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => '?')

              line.strip!
              line.sub!("\n", '')
              line.downcase!
              line.gsub!(/\A\p{Alnum}+\z/i, '')

              words = line.split(' ')

              words.each do |word|
                unless word.length < 3 || word !~ /\A\p{Alnum}+\z/ || word.length > 17
                  if words_hash.has_key?(word)
                    words_hash[word] += 1
                  else
                    words_hash[word] = 1
                  end
                  if all_words.has_key?(word)
                    all_words[word] += 1
                  else
                    all_words[word] = 1
                  end
                end
              end
           end
            tmp_file.close
            log.write " Closed #{file}.\n"
            puts " Closed #{file}"
          end

        end
      end

      words_hash.each_key do |key|
        new_file.write("#{key}, #{words_hash[key]}\n")
      end
      new_file.close
      log.write("Finished writing #{entry}.csv.\n")
      Dir.chdir("..")
    end
  end
  all_words_file = File.new('allWords.csv','w+')
  log.write("Writing allWords.csv file.\n")
  puts 'Writing allWords.csv file.'
  all_words.each_key do |key|
    all_words_file.write("#{key}, #{all_words[key]}\n")
  end
  all_words_file.close
  log.write('Finished writing allWords.csv\n')
  log.write "Closing Log File.\n"
  log.close
end









