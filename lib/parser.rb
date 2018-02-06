require 'json'
require 'rest-client'
require 'uri'

$language = ""

class String
    def camelize
      filtered = self.split('_').select {|v| v != ""}
      if self == ""
        return "null"
      end
      camel_text = filtered[1..-1].collect(&:cap_capitalize).join
      camel_text = filtered.first.nil? ? self : (filtered.first + camel_text)
      camel_text.unHyphoniezed
    end
  
    def unHyphoniezed
      splitted = self.split('-')
      camel_text = splitted[1..-1].collect(&:cap_capitalize).join
      splitted.first.nil? ? self : (splitted.first + camel_text)
    end

    def cap_capitalize
      self.capitalize
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

  def create_file filename, content, extension='.swift'
    _filename = filename + extension
        File.open(_filename,  "w") do |file|
            file.write content
            puts "created file #{_filename}"
            # puts content
        end
      # end
  end

  def get_attribute_literal_prefix
    @realm ? "@objc dynamic " : ""
  end

  def get_array_attribute_literal type
    @realm ? " = List<#{type.cap_capitalize.camelize}>()" : ": [#{type.cap_capitalize}] = []"
  end

  def get_array_mapping_literal type
    @realm ? "(map[\"#{type}\"], ListTransform<#{type.cap_capitalize.camelize}>())" : "map[\"#{type}\"]"
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
          @parsed.store(key.cap_capitalize.camelize, newSwiftClass)
          attribute = Attribute.new(key, "#{key}")
          swiftClassAttributes.push(attribute)
        elsif value.is_a? Array
          if value.first.is_a? Hash
            newSwiftClass = generate_attributes_literals value.first
            @parsed.store(key.cap_capitalize.camelize, newSwiftClass)
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
        newSwiftClass = generate_attributes_literals json.first
        @parsed.store("TOPLEVELCONTAINER", newSwiftClass)
      end
    end
    # swiftClass
    swiftClassAttributes
  end

  def parse!
    $language = "swift"
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
          attribute_literal = "\t\tvar #{attribute.name.camelize}#{get_array_attribute_literal attribute.type_name}\n"
          mapping_literal = "\t\t\t\t#{attribute.name.camelize} <- #{get_array_mapping_literal attribute.type_name}\n"
        else
          default_value = attribute.default_value
          default_value = default_value.nil? ? "?" : " = #{default_value}"
          attribute_literal = "\t\t#{get_attribute_literal_prefix}var #{attribute.name.camelize}: #{attribute.type_name.cap_capitalize}#{default_value}\n"
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
  $language = "swift"
  swiftClass = generate_attributes_literals @json
  if @json.is_a? Hash
    @parsed.store("Container", swiftClass)
  end
  all_content = ""
  @parsed.each do |class_name, attributes|
    attribute_literals = ""
    mapping_literals = ""
    key_literals = ""
    attributes.each do |attribute|
      attribute_literal = ""
      mapping_literal = ""
      key_literal = ""
      if attribute.is_array
        attribute_literal = "\tlet #{attribute.name.camelize}: [#{attribute.type_name.cap_capitalize.camelize}]\n"
      else
        attribute_literal = "\tlet #{attribute.name.camelize}: #{attribute.type_name.cap_capitalize.camelize}\n"
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

struct #{class_name} {
#{attribute_literals}
}

extension #{class_name}: Mappable {
\tinit(map: Mapper) throws {
#{mapping_literals}
\t}

\tstruct Key {
#{key_literals}
\t}
}\n
CLASS
    all_content += ("\n\n"  + class_model)
    create_file class_name, class_model
  end
  create_file "ALLCONTENT", all_content
end

# parser for android
def parseForAndroid!
  $language = "java"
  swiftClass = generate_attributes_literals @json
  if @json.is_a? Hash
    @parsed.store("Container", swiftClass)
  end
  all_content = ""
  @parsed.each do |class_name, attributes|
    attribute_literals = ""
    getter_setter_literals = ""
    attributes.each do |attribute|
      attribute_literal = ""
      getter_setter_literal = ""
      if attribute.is_array
        attribute_literal = <<-Attribute
\t@SerializedName(\"#{attribute.name}\")
\t@Expose
\tprivate List<#{attribute.type_name.cap_capitalize.camelize}> #{attribute.name.camelize} = null;\n
Attribute
        getter_setter_literal = <<-GETTER
\tpublic List<#{attribute.type_name.cap_capitalize.camelize}> get#{attribute.name.camelize.cap_capitalize}() {
\t\treturn #{attribute.name.camelize};
\t}

\tpublic void set#{attribute.name.camelize.cap_capitalize}(List<#{attribute.type_name.cap_capitalize.camelize}> #{attribute.name.camelize}) {
\t\tthis.#{attribute.name.camelize} = #{attribute.name.camelize};
\t}\n
GETTER
      else
        attribute_literal = <<-Attribute
\t@SerializedName(\"#{attribute.name}\")
\t@Expose
\tprivate #{attribute.type_name.cap_capitalize.camelize} #{attribute.name.camelize};\n
Attribute

      getter_setter_literal = <<-GETTER
\tpublic #{attribute.type_name.cap_capitalize.camelize} get#{attribute.name.camelize.cap_capitalize}() {
\t\treturn #{attribute.name.camelize};
\t}

\tpublic void set#{attribute.name.camelize.cap_capitalize}(#{attribute.type_name.cap_capitalize.camelize} #{attribute.name.camelize}) {
\t\tthis.#{attribute.name.camelize} = #{attribute.name.camelize};
\t}\n
GETTER

      end
      attribute_literals += attribute_literal
      getter_setter_literals += getter_setter_literal
      
    end

    class_model = <<-CLASS
//
// Created with veda-apps.
// https://rubygems.org/gems/veda-apps
//

// package com.example;
import java.util.List;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class #{class_name} {
#{attribute_literals}
#{getter_setter_literals}
}
CLASS
    all_content += ("\n\n"  + class_model)
    create_file class_name, class_model, ".java"
  end
  create_file "ALLCONTENT", all_content
end
 
end

class Attribute
  attr_accessor :name, :type, :is_array
  def initialize name, type, is_array=false
    @name = name
    @type = type
    @is_array = is_array
  end

  def type_name
    puts "--#{@type}--#{name}--#{$language}--"
    result = @type
    case @type
    when "String"
      result = "String"
    when "Int"
      case $language
      when "swift"
        result = "Int"
      when "kotlin"
        result = "Int"
      when "java"
        result = "Integer"
      end
    when "Double"
      result = "Double"
    when "Bool"
      case $language
      when "swift"
        result = "Bool"
      when "kotlin"
        result = "Boolean"
      when "java"
        result = "boolean"
      end
    end
    result
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
