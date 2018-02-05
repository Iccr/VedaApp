require 'json'
require 'rest-client'
require 'uri'


class String
    def camelize
      filtered = self.split('_').select {|v| v != ""}
      camel_text = filtered[1..-1].collect(&:capitalize).join
      camel_text = filtered.first.nil? ? self : (filtered.first + camel_text)
      camel_text.unHyphoniezed
    end
  
    def unHyphoniezed
      splitted = self.split('-')
      camel_text = splitted[1..-1].collect(&:capitalize).join
      splitted.first.nil? ? self : (splitted.first + camel_text)
    end
  end

class Parser
  def initialize path, realm=false
    json = File.read(path)
    @json = JSON.parse(json)
    @realm = realm
    @parsed = {}
  end

  def load_from_config path
    config = File.read(path)
    config_json = JSON.parse(config)
    @url = config_json["url"]
    @headers = config_json["headers"]
    if @url =~ URI::regexp
      self.fetch!
    else
      puts "ERROR: URL in config.json is not valid. please add valid url."
    end
  end

  def fetch!
    puts 'fetching'
    json = RestClient.get(@url, headers = @headers)
    puts 'fetched'
    @json = JSON.parse(json)
    self.parse!
  end


  def attribute_type attribute
    result = ""
    if attribute.is_a? String
      result = "String"
    elsif attribute.is_a? Integer
      result = "Int"
    elsif attribute.is_a? Float
      result = "Double"
    elsif !!attribute == attribute
      result = "Bool"
    end
    result
  end

  def create_file filename, content
    _filename = filename + ".swift"
        File.open(_filename,  "w") do |file|
            file.write content
            puts "created file #{_filename}"
        end
      # end
  end

  def get_attribute_literal_prefix
    @realm ? "@objc dynamic " : ""
  end

  def get_array_attribute_literal type
    @realm ? " = List<#{type.capitalize.camelize}>()" : ": [#{type.capitalize}] = []"
  end

  def get_array_mapping_literal type
    @realm ? "(map[\"#{type}\"], ListTransform<#{type.capitalize.camelize}>())" : "map[\"#{type}\"]"
  end

  def generate_attributes_literals json
    swiftClassAttributes = []
    swiftClass = ""
    # take all hash
    if json.is_a? Hash
      # loop on each key value pair
      json.each do |key, value|
        # if value is not array or hash it is a attribute
        if !(value.is_a? Array) && !(value.is_a? Hash)
          attribute = Attribute.new(key, "#{attribute_type value}")
          swiftClassAttributes.push(attribute)
        elsif value.is_a? Hash
          newSwiftClass = generate_attributes_literals value
          @parsed.store(key.capitalize.camelize, newSwiftClass)
          attribute = Attribute.new(key, "#{key}")
          swiftClassAttributes.push(attribute)
        elsif value.is_a? Array
          if value.first.is_a? Hash
            newSwiftClass = generate_attributes_literals value.first
            @parsed.store(key.capitalize.camelize, newSwiftClass)
            attribute = Attribute.new(key, "#{key}", true)
            swiftClassAttributes.push(attribute)
          else
            attribute = Attribute.new(key, "#{attribute_type value.first}", true)
            swiftClassAttributes.push(attribute)
          end
        end
      end
    elsif json.is_a? Array
      if json.first.is_a? Hash
        generate_attributes_literals json.first
      end
    end
    # swiftClass
    swiftClassAttributes
  end

  def parse!
    swiftClass = generate_attributes_literals @json
    if @json.is_a? Hash
      @parsed.store("Container", swiftClass)
    end

    @parsed.each do |class_name, attributes|
      realm_funcs = <<-REALMCLASS
\t\trequired convenience init?(map: Map) {
\t\t\t\tself.init()
\t\t}

\t\toverride class func primaryKey() -> String? {
\t\t\t\t// change according to your requirement
\t\t\t\treturn "id"
\t\t}
REALMCLASS

      non_realm_funcs = <<-DEFAULT
\t\trequired init?(map: Map) {
\t\t}
DEFAULT
      # (map["friends"], ListTransform<User>())
      attribute_literals = ""
      mapping_literals = ""
      attributes.each do |attribute|
        attribute_literal = ""
        mapping_literal = ""
        if attribute.is_array
          attribute_literal = "\t\tvar #{attribute.name.camelize}#{get_array_attribute_literal attribute.type}\n"
          mapping_literal = "\t\t\t\t#{attribute.name.camelize} <- #{get_array_mapping_literal attribute.type}\n"
        else
          default_value = attribute.default_value
          default_value = default_value.nil? ? "?" : " = #{default_value}"
          attribute_literal = "\t\t#{get_attribute_literal_prefix}var #{attribute.name.camelize}: #{attribute.type.capitalize}#{default_value}\n"
          mapping_literal = "\t\t\t\t#{attribute.name.camelize} <- map[\"#{attribute.name}\"]\n"
        end
        attribute_literals += attribute_literal
        mapping_literals += mapping_literal
      end

      class_model = <<-CLASS
//
// Created with veda-apps.
// https://rubygems.org/gems/veda-apps
//
import Foundation
import ObjectMapper
#{@realm? "import RealmSwift\nimport ObjectMapper_Realm" : ""}

class #{class_name}:#{@realm? " Object," : ""} Mappable {
#{attribute_literals}
#{@realm? realm_funcs : non_realm_funcs}
\t\tfunc mapping(map: Map) {
#{mapping_literals}
\t\t}
}\n
CLASS
      create_file class_name, class_model
    end
  end


 # parser for moya model mapper
 def parseForMoya!
  
  swiftClass = generate_attributes_literals @json
  if @json.is_a? Hash
    @parsed.store("Container", swiftClass)
  end

  @parsed.each do |class_name, attributes|
    attribute_literals = ""
    mapping_literals = ""
    key_literals = ""
    attributes.each do |attribute|
      attribute_literal = ""
      mapping_literal = ""
      key_literal = ""
      if attribute.is_array
        attribute_literal = "\tlet #{attribute.name.camelize}: [#{attribute.type.capitalize.camelize}]\n"
      else
        attribute_literal = "\tlet #{attribute.name.camelize}: #{attribute.type.capitalize.camelize}\n"
      end
      mapping_literal = "\t\t#{attribute.name.camelize} = try map.from(Key.#{attribute.name.camelize})\n"
      key_literal = "\t\tstatic let #{attribute.name.camelize} = \"#{attribute.name}\"\n"
      attribute_literals += attribute_literal
      mapping_literals += mapping_literal
      key_literals += key_literal
    end

    class_model = <<-CLASS
//
// Created with veda-apps.
// https://rubygems.org/gems/veda-apps
//
import Foundation
import Moya
import Mapper

struct #{class_name}: Mappable {
#{attribute_literals}
\tinit(map: Mapper) throws {
#{mapping_literals}
\t}

\tstruct Key {
#{key_literals}
\t}
}\n
CLASS
    create_file class_name, class_model
  end
end
 
end

class Attribute
  attr_accessor :name, :type, :is_array
  def initialize name, type, is_array=false
    @name = name
    @type = type
    @is_array = is_array
  end

  def default_value
    result = nil
    case @type
    when "String"
      result = "\"\""
    when "Int"
      result = 0
    when "Double"
      result = 0.0
    when "Bool"
      result = false
    end
    result
  end
end
