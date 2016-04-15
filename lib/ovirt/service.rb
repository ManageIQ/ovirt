require 'nokogiri'

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

    attr_accessor :session_id

    def self.name_to_class(name)
      Ovirt.const_get(name.camelize)
    end

    def xml_to_object(klass, xml)
      klass.create_from_xml(self, xml)
    end

    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      parse_domain_name
      REQUIRED_OPTIONS.each { |key| raise "No #{key} specified" unless @options.key?(key) }
      @password   = @options.delete(:password)
      @session_id = @options[:session_id]
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
    end

    def get_resource_by_ems_ref(uri_suffix, element_name = nil)
      xml            = resource_get(uri_suffix)
      doc            = Nokogiri::XML(xml)
      element_name ||= doc.root.name
      klass          = self.class.name_to_class(element_name)
      xml_to_object(klass, doc.root)
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

    def api_uri(path = nil)
      uri = "#{base_uri}/api"
      unless path.nil?
        parts = path.to_s.split('/')
        parts.shift if parts.first == ''    # Remove leading slash
        parts.shift if parts.first == 'api' # We already have /api in our URI
        uri += "/#{parts.join('/')}" unless parts.empty?
      end
      uri
    end

    def self.ovirt?(options)
      options[:username] = options[:password] = "_unused"
      !new(options).engine_ssh_public_key.to_s.blank?
    rescue RestClient::ResourceNotFound, NoMethodError
      false
    end

    def engine_ssh_public_key
      require "rest-client"
      RestClient::Resource.new("#{base_uri}/engine.ssh.key.txt", resource_options).get
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

    def resource_get(path = nil)
      resource_verb(path, :get)
    end

    def resource_put(path, payload, additional_headers = {:content_type => :xml, :accept => :xml})
      resource_verb(path, :put, payload, additional_headers)
    end

    def resource_post(path, payload, additional_headers = {:content_type => :xml, :accept => :xml})
      resource_verb(path, :post, payload, additional_headers)
    end

    def resource_delete(path)
      resource_verb(path, :delete)
    end

    def create_resource(path = nil)
      require "rest-client"
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
          response.return!(request, result, &block)
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
      require 'uri'
      uri = URI::Generic.build(:scheme => scheme.to_s, :port => port)
      uri.hostname = server
      uri.to_s
    end

    def resource_options
      headers = merge_headers('Prefer' => 'persistent-auth')
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
  end
end
