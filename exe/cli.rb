#!/usr/bin/env ruby

require_relative "../lib/pbom"

# Parse command-line arguments and call the appropriate functions
# This is just a placeholder. Replace this with your actual CLI code.
if ARGV.empty?
  puts "Usage: pbom [command]"
else
  command = ARGV.first
  case command
  when "generate"
    puts "Generating a new PBOM..."
    # TODO input_path and output_path should be parsed from the command line
    Pbom::Generator.new.generate
  when "version"
    puts "PBOM version #{Pbom::VERSION}"
  else
    puts "Unknown command: #{command}"
  end
end