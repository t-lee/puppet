#!/usr/bin/env ruby

required_doc_files = {
    "bliss_creator" => false,
    "bliss_created" => false,
    "bliss_maintainer" => false,
    "bliss_purpose" => false, 
}

WARNING = 1

if File.exist?('/etc/doc')
  Dir.foreach('/etc/doc') do |file|
    required_doc_files[file] = true if required_doc_files.keys.include?(file)    
  end
  
  missing_files = []
  required_doc_files.each_pair do |file,file_exist|
    missing_files << file unless file_exist
  end
  
  case missing_files.size
  when 0
    puts "DOC OK - purpose: #{IO.read('/etc/doc/bliss_purpose')}"
    exit 0
  when 4
    puts "WARNING - doc files missing: please read /etc/doc/README."
    exit WARNING
  when 1
    puts "WARNING - one file missing: #{missing_files.first}."
    exit WARNING
  else
    puts "WARNING - #{missing_files.size} files missing in /etc/doc/: #{missing_files.join(", ")}."
    exit WARNING
  end
  
  
else
  puts "WARNING - NO DOC: dir /etc/doc does not exist."
  exit WARNING
end
