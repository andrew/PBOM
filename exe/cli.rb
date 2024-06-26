#!/usr/bin/env ruby

require_relative "../lib/pbom"

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: generate [options]"

  opts.on("--input PATH", "Set the input path") do |path|
    options[:input_path] = path
  end
  opts.on("--output PATH", "Set the output path") do |path|
    options[:output_path] = path
  end
end.parse!

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
    input_path = options[:input_path] || "."
    output_path = options[:output_path] || "."
    Pbom::Generator.new(input_path: input_path, output_path: output_path).generate
  when "version"
    puts "PBOM version #{Pbom::VERSION}"
  else
    puts "Unknown command: #{command}"
  end
end