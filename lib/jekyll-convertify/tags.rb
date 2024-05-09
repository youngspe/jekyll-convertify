module Convertify; module TagHelper
  @@include_pattern = /\A(.*)\s+as\s+(\S+)\s*\Z/
  def self.split_include_markup(markup)
    match_data = @@include_pattern.match(markup)
    match_data&.captures || [markup, nil]
  end
end; end

module Jekyll
  class ConvertifyBlock < Liquid::Block
    @@pattern = /\A\s*from\s*(\S+)\s*(?:to\s*(\S+)\s*\Z)?/

    def initialize(tag_name, markup, tokens)
      super
      match_data = @@pattern.match(markup)
      raise Liquid::Error, "Expected {% #{tag_name} from .<SRC> [to .<DEST>] %}" unless match_data
      @src_ext = match_data.captures[0]
      @dst_ext = match_data.captures[1]
    end

    def render(context)
      Convertify.convert(context, lambda { super }, @src_ext, @dst_ext)
    end
  end

  class ConvertifyIncludeTag < Jekyll::Tags::IncludeTag
    @dst_ext = nil

    def initialize(tag_name, markup, tokens)
      markup, @dst_ext = Convertify::TagHelper::split_include_markup(markup)
      super tag_name, markup, tokens
    end

    def locate_include_file(context, file, safe)
      @src_ext = Convertify::ConvertHelper::infer_extension(file)
      super
    end

    def render(context)
      context.stack do
        context["convertify_extension"] = @dst_ext
        input = super
        Convertify.convert(context, lambda { input }, @src_ext, @dst_ext)
      end
    end
  end

  class ConvertifyIncludeRelativeTag < Jekyll::Tags::IncludeRelativeTag
    @dst_ext = nil

    def initialize(tag_name, markup, tokens)
      markup, @dst_ext = Convertify::TagHelper::split_include_markup(markup)
      super tag_name, markup, tokens
    end

    def locate_include_file(context, file, safe)
      @src_ext = Convertify::ConvertHelper::infer_extension(file)
      super
    end

    def render(context)
      context.stack do
        context["convertify_extension"] = @dst_ext
        input = super
        Convertify.convert(context, lambda { input }, @src_ext, @dst_ext)
      end
    end
  end
end

Liquid::Template.register_tag("convertify", Jekyll::ConvertifyBlock)
Liquid::Template.register_tag("convertify_include", Jekyll::ConvertifyIncludeTag)
Liquid::Template.register_tag("convertify_include_relative", Jekyll::ConvertifyIncludeRelativeTag)
