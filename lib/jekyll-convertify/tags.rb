module Convertify
  @@include_pattern = /\A(.*)\s+as\s+(\S+)\s*\Z/
  def self.split_include_markup(markup)
    match_data = @@include_pattern.match(markup)
    match_data&.captures || [markup, nil]
  end
end

module Jekyll
  class ConvertifyBlock < Liquid::Block
    @@pattern = /\A\s*from\s*(\S+)\s*(?:to\s*(\S+)\s*\Z)?/

    def initialize(tag_name, markup, tokens)
      super
      match_data = @@pattern.match(markup)
      raise Liquid::Error, "Expected {% #{tag_name} from .<SRC> [to .<DEST>] %}" unless match_data
      @source_extension = match_data.captures[0]
      @dest_extension = match_data.captures[1]
    end

    def render(context)
      Convertify.convert(context, lambda { super }, @source_extension, @dest_extension)
    end
  end

  class ConvertifyIncludeTag < Jekyll::Tags::IncludeTag
    @dest_extension = nil

    def initialize(tag_name, markup, tokens)
      markup, @dest_extension = Convertify::split_include_markup(markup)
      super(tag_name, markup, tokens)
    end

    def read_file(file, context)
      source_extension = Convertify.infer_extension(file)
      Convertify.convert(context, lambda { super }, source_extension, @dest_extension)
    end
  end
end

Liquid::Template.register_tag("convertify", Jekyll::ConvertifyBlock)
Liquid::Template.register_tag("convertify_include", Jekyll::ConvertifyIncludeTag)
