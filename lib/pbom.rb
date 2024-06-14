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

      # step 4 output finished message
      puts "PBOM generated at #{output_path}"
      puts "  - sbom.json"
      puts "  - references.bib"
    end

    def load_purls
      load_sbom['packages'].map do |artifact|
        # find purl for each package
        next if artifact.nil? || artifact['externalRefs'].nil?
        purl = artifact['externalRefs'].find { |ref| ref['referenceType'] == 'purl' }&.fetch('referenceLocator', nil)
        @packages << Package.new(purl) if purl
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
        @packages.each do |purl|
          f.puts generate_bib_entry(purl)
        end
      end
    end

    def generate_bib_entry(package)
      <<~BIB
        @misc{#{package.to_reference},
          title = {#{package.to_s}},
          version = {#{package.version}},
          url = {#{package.url}},
          license = {#{package.licenses}},
        }
      BIB
    end
  end
end
