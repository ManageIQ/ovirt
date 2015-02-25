module Ovirt
  class Parser
    attr_accessor :definition

    def initialize(definition)
      @definition = definition
    end

    def parse(node)
      hash = parse_object(node)
      hash.merge!(
        :actions       => parse_actions(node),
        :relationships => parse_relationships(node)
      )
      hash.merge!(parse_node(node))
      hash
    end

    private

    OBJECT_DEFINITION = {
      "id"   => "string",
      "href" => "string"
    }.freeze

    VERSION_DEFINITION = {
      "major"        => "string",
      "minor"        => "string",
      "build"        => "string",
      "revision"     => "string",
      "full_version" => "string"
    }.freeze

    def parse_type(node, type)
      meth = "parse_#{type}"
      send(meth, node) if respond_to?(meth, true)
    end

    def parse_attributes(node, attributes)
      attributes.each_with_object({}) do |(key, type), h|
        value = send("cast_#{type}", node[key])
        h[key.to_sym] = value unless parsed_blank?(value)
      end
    end

    def parse_node(node, definition = @definition, hash = {})
      definition.each do |key, type|
        case type
        when String
          # String states we have a simple node of the form <key>value</key>
          #   where value is of the type defined by the String.
          parse_node(node, {key => {"type" => type}}, hash)
        when Hash
          # Hash states we have a complex node.  Valid keys are:
          #   type: The type of the node's text
          #   attributes: The node's attributes and their types
          #   nodes: The subnodes, which will be recursively parsed

          child_node = node.xpath(key).first
          next unless child_node

          if type["attributes"]
            parsed = parse_attributes(child_node, type["attributes"])
            update_hash(hash, key, parsed)
          end

          if type["nodes"]
            parsed = parse_node(child_node, type["nodes"])
            update_hash(hash, key, parsed)
          end

          if type["type"]
            parsed = parse_type(child_node, type["type"])
            unless parsed_blank?(parsed)
              # If both type and either attributes or nodes are specified,
              #   then the value can't be placed in the results directly.
              #   Instead, create a key called :value and merge it into the
              #   Hash.
              parsed = {:value => parsed} if hash.key?(key.to_sym)

              update_hash(hash, key, parsed)
            end
          end
        end
      end

      hash
    end

    def parsed_blank?(parsed)
      parsed.blank? && parsed != false
    end

    def update_hash(hash, key, parsed)
      return if parsed_blank?(parsed)
      key = key.to_sym
      hash[key] = hash.key?(key) ? hash[key].merge(parsed) : parsed
    end

    def parse_relationships(node)
      parse_links(node, 'link')
    end

    def parse_actions(node)
      parse_links(node, 'actions/link')
    end

    def parse_links(node, path)
      node.xpath(path).each_with_object({}) do |link, h|
        h[link['rel'].to_sym] = link['href']
      end
    end

    def parse_object(node)
      parse_attributes(node, OBJECT_DEFINITION)
    end

    def parse_version(node)
      parse_attributes(node, VERSION_DEFINITION)
    end

    def parse_string(node)
      cast_string(node.try(:text))
    end

    def parse_integer(node)
      cast_integer(node.try(:text))
    end

    def parse_boolean(node)
      cast_boolean(node.try(:text))
    end

    def cast_string(text)
      text && text.to_s
    end

    def cast_integer(text)
      text && text.to_i
    end

    def cast_boolean(text)
      text && text == "true"
    end
  end
end
