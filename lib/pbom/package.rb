require 'package_url'
require 'faraday'
require 'cff'

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
      @citation = nil
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
        download_citation_cff
      end
    end

    def matches?(other_purl)
      other_parse_purl = PackageURL.parse(other_purl)
      return false if @type != other_parse_purl.type
      return false if @namespace != other_parse_purl.namespace
      return false if @name != other_parse_purl.name
      true
    end

    def title
      "#{@name} (#{@version})"
    end

    def to_reference
      [@type, @namespace, @name].compact.join(':')
    end

    def to_cite
      "\\cite{#{to_reference}}"
    end

    def url
      @details['homepage'] || @details['repository_url'] || @details['registry_url'] 
    end

    def licenses
      @details['licenses']
    end

    def year
      @details['latest_release_published_at']&.split('-')&.first
    end

    def month
      (@details['latest_release_published_at']&.split('-') || [])[1]
    end

    def authors
      Array(@details['maintainers']).map{ |m| m['name'] || m['login'] }.join(', ')
    end

    def howpublished
      if @details['registry']
        "Published on #{@details['registry']['url']}"
      else
        "Retrieved from #{purl}"
      end
    end

    def download_citation_cff
      if @details['repo_metadata'] && @details['repo_metadata']['metadata'] && @details['repo_metadata']['metadata']['files'] && @details['repo_metadata']['metadata']['files']['citation']
        
        path = @details['repo_metadata']['metadata']['files']['citation']
        return unless path.end_with?('.cff')
        puts "Downloading #{path} from #{@details['repo_metadata']['full_name']}..."
        branch = @details['repo_metadata']['default_branch'] || 'master' 
        
        url = "https://raw.githubusercontent.com/#{@details['repo_metadata']['full_name']}/#{branch}/#{path}"

        response = Faraday.get(url)
        if response.status == 200
          @citation = response.body
        end
      end
    end

    def render_citation_cff
      begin
        cff = CFF::Index.read(@citation)
        cff.to_bibtex
      rescue StandardError
        nil
      end
    end

    def generate_bib_entry
      return render_citation_cff if @citation
      <<~BIB
        @software{#{to_reference},
          author = {#{authors}},
          title = {{#{title}}},
          version = {#{version}},
          url = {#{url}},
          license = {#{licenses}},
          year = {#{year}},
          month = {#{month}},
          howpublished = {#{howpublished}}
        }
      BIB
    end

  end
end