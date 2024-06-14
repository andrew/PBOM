# frozen_string_literal: true

require_relative "pbom/version"
require_relative "pbom/package"
require 'json'

module Pbom
  class Error < StandardError; end
  
  class Generator
    attr_reader :input_path, :output_path, :packages

    def initialize(input_path: '.', output_path: '.')
      @input_path = input_path
      @output_path = output_path
      @packages = []
    end

    def generate
      generate_sbom

      load_purls

      generate_references_bib

      puts "PBOM generated at #{output_path}"
      puts "  - #{packages.count} unique packages found"
      puts "  - sbom.json"
      puts "  - references.bib"
      puts 
      puts "To cite all packages in your research, add the following to your LaTeX document:"
      puts
      puts generate_cite_list
      puts
    end

    def load_purls
      load_sbom['packages'].map do |artifact|
        next if artifact.nil? || artifact['externalRefs'].nil?
        purl = artifact['externalRefs'].find { |ref| ref['referenceType'] == 'purl' }&.fetch('referenceLocator', nil)
        if purl
          next if @packages.any? { |pkg| pkg.matches?(purl) }
          @packages << Package.new(purl) 
        end
      end
    end

    def generate_sbom
      `syft scan #{input_path} -o spdx-json=#{output_path}/sbom.json > /dev/null 2>&1`
    end

    def load_sbom
      JSON.parse(File.read("#{output_path}/sbom.json"))
    end

    def generate_references_bib
      File.open("#{output_path}/references.bib", "w") do |f|
        packages.each do |package|
          f.puts package.generate_bib_entry
        end
      end
    end

    def generate_cite_list
      packages.map(&:to_cite).join(", ")
    end
  end
end
