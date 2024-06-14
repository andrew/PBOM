# frozen_string_literal: true

require_relative "pbom/version"
require 'json'

module Pbom
  class Error < StandardError; end
  
  class Generator
    attr_reader :input_path, :output_path

    def initialize(input_path: '.', output_path: '.')
      @input_path = input_path
      @output_path = output_path
    end

    def generate
      # step 1 generate sbom using syft
      generate_sbom

      # step 2 read sbom and fetch extra metadata for each package
      sbom = load_sbom

      # step 3 read sbom and output references.bib
      generate_references_bib(sbom)

      # step 4 output finished message
      puts "PBOM generated at #{output_path}"
      puts "  - sbom.json"
      puts "  - references.bib"
    end

    def generate_sbom
      `syft scan #{input_path} -o spdx-json=#{output_path}/sbom.json > /dev/null 2>&1`
    end

    def load_sbom
      JSON.parse(File.read("#{output_path}/sbom.json"))
    end

    def generate_references_bib(sbom)
      File.open("#{output_path}/references.bib", "w") do |f|
        sbom["packages"].each do |artifact|
          f.puts generate_bib_entry(artifact)
        end
      end
    end

    def generate_bib_entry(artifact)
      <<~BIB
        @misc{#{artifact["name"]},
          title = {#{artifact["name"]}},
          version = {#{artifact["version"]}},
          url = {#{artifact["packageLocation"]}}
        }
      BIB
    end
  end
end
