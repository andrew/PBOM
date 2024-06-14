require 'package_url'
require 'faraday'

module Pbom
  class Package
    attr_reader :name, :version, :purl, :details

    def initialize(purl)
      @purl = purl
      parse_purl = PackageURL.parse(purl)
      @type = parse_purl.type
      @namespace = parse_purl.namespace
      @name = parse_purl.name
      @version = parse_purl.version
      @qualifiers = parse_purl.qualifiers
      @subpath = parse_purl.subpath
      @details = {}
      fetch_details
    end

    def fetch_details
      puts "Looking up #{@purl}..."
      response = Faraday.get("https://packages.ecosyste.ms/api/v1/packages/lookup?purl=#{@purl}")
      if response.status == 200
        data = JSON.parse(response.body)
        pkg = data.first
        return if pkg.nil?
        @details = pkg
      end
    end

    def to_s
      "#{@name} #{@version}"
    end

    def to_reference
      [@type, @namespace, @name].compact.join(':')
    end

    def url
      @details['registry_url'] || @details['repository_url'] || @details['homepage']
    end

    def licenses
      @details['licenses']
    end

    def authors
      # TBD
    end

  end
end