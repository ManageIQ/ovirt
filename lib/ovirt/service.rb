require 'nokogiri'
require 'openssl'
require 'rest-client'
require 'tempfile'
require 'uri'

module Ovirt
  class Service
    include Logging

    DEFAULT_OPTIONS  = {}
    REQUIRED_OPTIONS = [:server, :username, :password]
    DEFAULT_PORT_3_0 = 8443
    DEFAULT_PORT_3_1 =  443
    DEFAULT_PORT     = DEFAULT_PORT_3_1
    DEFAULT_SCHEME   = 'https'.freeze
    SESSION_ID_KEY   = 'JSESSIONID'.freeze

    # The list of absolute URI paths where the API can be available:
    CANDIDATE_API_PATHS = [
      '/api',
      '/ovirt-engine/api',
    ].freeze

    # The list of absolute URI paths where the engine SSH public key can be available (this is used only to detect if
    # the engine is installed or not):
    CANDIDATE_SSH_PUBLIC_KEY_PATHS = [
      # This will work for newer versions of the engine, including 3.5, 3.6 and 4.0:
      '/ovirt-engine/services/pki-resource?resource=engine-certificate&format=OPENSSH-PUBKEY',

      # This will work for older versions of the engine older thatn 3.5:
      '/engine.ssh.key.txt',
    ].freeze

    attr_accessor :session_id

    def self.name_to_class(name)
      Ovirt.const_get(name.camelize)
    end

    def xml_to_object(klass, xml)
      klass.create_from_xml(self, xml)
    end

    #
    # Creates a new logical connection to the server.
    #
    # @param options [Hash] The options used to create the instance.
    #
    # @option options [String] :ca_certs A string containing the trusted CA certificates, in PEM format. Multiple
    #   certificates can be provided concatenating them as a single string. If this option isn't provided then
    #   the system wide trusted CA certificates will be used.
    #
    # Note that there are other options that aren't documented yet.
    #
    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      parse_domain_name
      REQUIRED_OPTIONS.each { |key| raise "No #{key} specified" unless @options.key?(key) }
      @password   = @options.delete(:password)
      @session_id = @options[:session_id]
      @api_path   = @options[:path]
      @ca_certs   = @options[:ca_certs]

      # The temporary file to store the CA certificates will be created when needed:
      @ca_file = nil
    end

    def inspect # just like the default inspect, but WITHOUT @password
      "#<#{self.class.name}:0x#{(object_id << 1).to_s(16).rjust(14, '0')} @options=#{@options.inspect}>"
    end

    def api(reload = false)
      @api   = nil if reload
      @api ||= xml_to_object(Api, resource_get)
    end

    def product_info
      @product_info ||= api[:product_info]
    end

    def name
      @name ||= product_info[:name]
    end

    def vendor
      @vendor ||= product_info[:vendor]
    end

    def version
      # HACK: using full_version if available due to version being wrong, https://bugzilla.redhat.com/show_bug.cgi?id=1284654
      @version ||= full_version || product_info[:version]
    end

    def version_string
      @version_string ||= "#{version[:major]}.#{version[:minor]}.#{version[:revision]}.#{version[:build]}"
    end

    def version_3_0?
      version_string.starts_with?("3.0")
    end

    def summary
      api(true)[:summary] # This is volatile information
    end

    def ca_certificate
      @ca_certificate ||= verify_certificate(get_ca_certificate)
    end

    def verify_certificate(certificate)
      return if certificate.to_s.strip.empty?

      require 'openssl'
      OpenSSL::X509::Certificate.new(certificate).to_s
    rescue OpenSSL::X509::CertificateError
    end

    def get_ca_certificate
      require "rest-client"
      RestClient::Resource.new("#{base_uri}/ca.crt", resource_options).get
    rescue RestClient::ResourceNotFound
    end

    def special_objects
      @special_objects ||= api[:special_objects]
    end

    def blank_template
      @blank_template ||= begin
        href = special_objects[:"templates/blank"]
        href.blank? ? nil : Template.find_by_href(self, href)
      end
    end

    def root_tag
      @root_tag ||= begin
        href = special_objects[:"tags/root"]
        href.blank? ? nil : Tag.find_by_href(self, href)
      end
    end

    def iso_storage_domain
      @iso_storage_domain ||= StorageDomain.iso_storage_domain(self)
    end

    def iso_images
      iso_storage_domain.nil? ? [] : iso_storage_domain.iso_images
    end

    def disconnect
      # Remove the temporary file that was created to store the trusted CA certificates:
      if @ca_file
        @ca_file.unlink
        @ca_file = nil
      end
    end

    def get_resource_by_ems_ref(uri_suffix, element_name = nil)
      xml            = resource_get(uri_suffix)
      doc            = Nokogiri::XML(xml)
      element_name ||= doc.root.name
      klass          = self.class.name_to_class(element_name)
      xml_to_object(klass, doc.root)
    end

    def get_resources_by_uri_path(uri_suffix, element_name = nil, xpath = nil)
      xml            = resource_get(uri_suffix)
      doc            = Nokogiri::XML(xml)
      element_name ||= doc.root.name
      klass          = self.class.name_to_class(element_name)
      xpath        ||= "//#{element_name}"
      objects        = doc.xpath(xpath)
      objects.collect { |obj| xml_to_object(klass, obj) }
    end

    def standard_collection(uri_suffix, element_name = nil, paginate = false, sort_by = :name, direction = :asc)
      if paginate
        doc = paginate_resource_get(uri_suffix, sort_by, direction)
      else
        xml = resource_get(uri_suffix)
        doc = Nokogiri::XML(xml)
      end
      element_name ||= uri_suffix.singularize
      klass          = self.class.name_to_class(element_name)

      xml_path = uri_suffix == 'api' ? element_name : "#{element_name.pluralize}/#{element_name}"
      objects  = doc.xpath("//#{xml_path}")
      objects.collect { |obj| xml_to_object(klass, obj) }
    end

    def status(link)
      response = resource_get(link)
      node     = Base.xml_to_nokogiri(response)
      node.xpath('status/state').text
    end

    # Checks if the API is available in the given candidate path. It does so sending a request without
    # authentication. If the API is available there it will respond with the "WWW-Autenticate" header
    # and with the "RESTAPI" or "ENGINE" realm.
    def probe_api_path(uri, path)
      uri = URI.join(uri, path)
      request = RestClient::Resource.new(uri.to_s, :verify_ssl => OpenSSL::SSL::VERIFY_NONE)
      begin
        request.get
      rescue RestClient::Exception => exception
        response = exception.response
        logger.error "#{self.class.name}#probe_api_path: exception probing uri: '#{uri}'. Exception: #{$ERROR_INFO}"
        return false if response.nil?
        if response.code == 401
          www_authenticate = response.headers[:www_authenticate]
          if www_authenticate =~ /^Basic realm="?(RESTAPI|ENGINE)"?$/
            return true
          end
        end
      end
      false
    end

    # Probes all the candidate paths of the API, and returns the first that success. If all probes
    # fail, then the first candidate will be returned.
    def find_api_path(uri)
      CANDIDATE_API_PATHS.detect { |path| probe_api_path(uri, path) } || CANDIDATE_API_PATHS.first
    end

    # Returns the path of the API, probing it if needed.
    def api_path
      @api_path ||= find_api_path(base_uri)
    end

    def api_uri(path = nil)
      # Calculate the complete URI:
      uri = URI.join(base_uri, api_path).to_s

      # The path passed to this method will have the "/api" prefix if it comes from the "ems_ref"
      # attribute stored in the database, and will have the "/ovirt-engine/api" if it comes directly
      # from the "href" attribute of the XML documents, for example when using the "relationships"
      # method to fetch secondary objects related to the primary object. This means that to have
      # a clean path we need to remove both "ovirt-engine" and "api".
      unless path.nil?
        parts = path.to_s.split('/')
        parts.shift if parts.first == ''
        parts.shift if parts.first == 'ovirt-engine'
        parts.shift if parts.first == 'api'
        uri += "/#{parts.join('/')}" unless parts.empty?
      end
      uri
    end

    def self.ovirt?(options)
      options[:username] = options[:password] = "_unused"
      !new(options).engine_ssh_public_key.blank?
    end

    def engine_ssh_public_key
      CANDIDATE_SSH_PUBLIC_KEY_PATHS.each do |path|
        begin
          key = RestClient::Resource.new("#{base_uri}#{path}", resource_options).get
          return key unless key.blank?
        rescue RestClient::ResourceNotFound, NoMethodError
          # Do nothing, just try the next candidate.
        end
      end
      nil
    end

    def paginate_resource_get(path = nil, sort_by = :name, direction = :asc)
      log_header = "#{self.class.name}#paginate_resource_get"
      page       = 1
      full_xml   = nil
      loop do
        uri = "#{path}?search=sortby%20#{sort_by}%20#{direction}%20page%20#{page}"
        partial_xml_str = resource_get(uri)
        if full_xml.nil?
          full_xml = Nokogiri::XML(partial_xml_str)
        else
          partial_xml = Nokogiri::XML(partial_xml_str)
          break if partial_xml.root.children.count == 0
          logger.debug "#{log_header}: Combining resource elements for <#{path}> from page:<#{page}>"
          full_xml.root << partial_xml.root.children
        end
        page += 1
      end
      logger.debug "#{log_header}: Combined elements for <#{path}>.  Total elements:<#{full_xml.root.children.count}>"
      full_xml
    end

    def resource_get(path = nil, additional_headers = {:accept => 'application/xml'})
      resource_verb(path, :get, additional_headers)
    end

    def resource_put(path, payload, additional_headers = {:content_type => 'application/xml', :accept => 'application/xml'})
      resource_verb(path, :put, payload, additional_headers)
    end

    def resource_post(path, payload, additional_headers = {:content_type => 'application/xml', :accept => 'application/xml'})
      resource_verb(path, :post, payload, additional_headers)
    end

    def resource_delete(path)
      resource_verb(path, :delete)
    end

    def create_resource(path = nil)
      RestClient::Resource.new(api_uri(path), resource_options)
    end

    private

    def resource_verb(path, verb, *args)
      log_header = "#{self.class.name}#resource_#{verb}"
      resource   = create_resource(path)
      logger.info "#{log_header}: Sending URL: <#{resource.url}>"
      logger.debug "#{log_header}: With args: <#{args.inspect}>"
      resource.send(verb, *args) do |response, request, result, &block|
        case response.code
        when 200..206
          parse_normal_response(response, resource)
        when 400..409
          parse_error_response(response, resource)
        else
          response.return!(&block)
        end
      end
    rescue RestClient::Unauthorized
      if session_id
        self.session_id = nil
        retry
      else
        raise
      end
    rescue RestClient::ResourceNotFound, Ovirt::Error
      raise
    rescue Exception => e
      logger.error("#{log_header}: class = #{e.class.name}, message=#{e.message}, URI=#{resource ? resource.url : path}")
      raise
    end

    def parse_normal_response(response, resource)
      parse_set_cookie_header(response.headers[:set_cookie])
      log_header = "#{self.class.name}#parse_normal_response"
      logger.info  "#{log_header}: Return from URL: <#{resource.url}> Data length:#{response.length}"
      logger.debug "#{log_header}: Return from URL: <#{resource.url}> Data:#{response}"
      response
    end

    def parse_error_response(response, resource)
      logger.error "#{self.class.name}#parse_error_response Return from URL: <#{resource.url}> Data:#{response}"
      raise Ovirt::MissingResourceError if response.code == 404
      raise RestClient::Unauthorized if response.code == 401
      doc    = Nokogiri::XML(response)
      action = doc.xpath("action").first
      node   = action || doc
      fault  = node.xpath("fault/detail").text
      usage  = node.xpath("usage_message/message").text
      raise Ovirt::Error, fault unless fault.blank?
      raise Ovirt::UsageError, usage
    end

    def parse_set_cookie_header(set_cookie_header)
      set_cookie_header = set_cookie_header.first if set_cookie_header.kind_of?(Array)
      set_cookie_header.to_s.split(";").each do |kv|
        k, v = kv.strip.split("=")
        self.session_id = v if k == SESSION_ID_KEY
      end
    end

    def base_uri
      uri = URI::Generic.build(:scheme => scheme.to_s, :port => port)
      uri.hostname = server
      uri.to_s
    end

    def resource_options
      headers = merge_headers(
        'Version' => '3',
        'Prefer'  => 'persistent-auth',
      )
      options = {}

      if session_id
        headers[:cookie]     = "#{SESSION_ID_KEY}=#{session_id}"
      else
        options[:user]       = fully_qualified_username
        options[:password]   = password
      end

      options[:headers]      = headers
      options[:timeout]      = timeout      if timeout
      options[:open_timeout] = open_timeout if open_timeout
      options[:verify_ssl]   = verify_ssl   unless verify_ssl.nil?
      options[:ssl_ca_file]  = ca_file.path if ca_file
      options
    end

    def merge_headers(hash)
      h = @options[:headers] || {}
      h.merge(hash)
    end

    def authorization_header
      @authorization_header ||= {:authorization => "Basic #{authorization_value}"}
    end

    def authorization_value
      @authorization_value ||= begin
        require "base64"
        Base64.encode64 "#{fully_qualified_username}:#{password}"
      end
    end

    def scheme
      @options[:scheme] || DEFAULT_SCHEME
    end

    def server
      @options[:server]
    end

    def port
      @options[:port] || DEFAULT_PORT
    end

    def fully_qualified_username
      domain.blank? ? username : "#{username}@#{domain}"
    end

    def username
      @options[:username]
    end

    attr_reader :password

    def domain
      @options[:domain]
    end

    def timeout
      @options[:timeout]        # NetHTTPSession's read_timeout
    end

    def open_timeout
      @options[:open_timeout]   # NetHTTPSessions's open_timeout
    end

    def verify_ssl
      @options[:verify_ssl]
    end

    # Parse domain out of the username string
    def parse_domain_name
      if @options[:domain].blank? && !@options[:username].blank?
        if @options[:username].include?('\\')
          @options[:domain], @options[:username] = username.split('\\')
        elsif @options[:username].include?('/')
          @options[:domain], @options[:username] = username.split('/')
        end
      end
    end

    def full_version
      v = product_info[:full_version]
      return if v.blank?
      v = v.sub("-", ".").split(".")[0..3]
      Hash[[:major, :minor, :revision, :build].zip(v)]
    end

    #
    # Returns a file object containing the trusted CA certificates. The file will be created if it
    # doesn't exist, and it shouldn't be removed or modified by the caller.
    #
    # @return [File] The temporary file containing the trusted CA certificates, or nil if no custom
    #   CA certificates are used by the connection.
    #
    def ca_file
      return unless @ca_certs
      @ca_file ||= Tempfile.new('ca_file').tap do |tempfile|
        tempfile.write(@ca_certs)
        tempfile.close
      end
    end
  end
end
