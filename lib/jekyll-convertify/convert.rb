module Convertify; module ConvertHelper
  def self.infer_extension(name)
    ext = name && File.extname(name)
    return nil if ext.nil? || ext.empty?
    ext
  end

  ConverterQuery = Struct.new :source_extension, :destination_extension, keyword_init: true
  ConverterResult = Struct.new :converter, :destination_extension, keyword_init: true

  # Find the converter for the given source and destination extensions
  def self.find_converter_with_dest(site, src_exts, dst_exts)
    converter = site.converters.find { |c|
      src_exts.any? { |src_ext|
        c.matches(src_ext) &&
        dst_exts.include?(c.output_ext(src_ext))
      }
    }
    converter && ConverterResult::new(
      converter: converter,
      destination_extension: dst_exts[0],
    )
  end

  def self.find_converter_any_dest(site, src_exts)
    # Find any converter for the given source extension
    converter = site.converters.find { |c|
      src_exts.any? { |src_ext|
        c.matches(src_ext) &&
        c.output_ext(src_ext) != src_ext
      }
    }
    converter && ConverterResult::new(
      converter: converter,
    )
  end

  def self.add_dot(extension)
    if extension.start_with? "."
      [extension]
    else
      [extension, "." + extension]
    end
  end

  def self.find_converter(context, src_ext, dst_ext)
    site = context.registers[:site]
    if src_ext == dst_ext
      return ConverterResult.new(
               converter: site.find_converter_instance(Jekyll::Converters::Identity),
               destination_extension: dst_ext,
             ) if src_ext == dst_ext
    end
    query = ConverterQuery.new(
      source_extension: src_ext,
      destination_extension: dst_ext,
    )
    cache = context.registers[:convertify_converter_cache] ||= {}

    src_exts = self.add_dot(src_ext)
    cached = cache[query]

    if dst_ext
      return cached if cached
      dst_exts = self.add_dot(dst_ext)

      result = self.find_converter_with_dest(site, src_exts, dst_exts)
      return cache[query] = result if result
      query.destination_extension = nil
      cached = cache[query]
    end

    return cached if cached
    result = self.find_converter_any_dest(site, src_exts)
    return cache[query] = result if result
  end
end; end

module Convertify
  def self.convert(context, render, source_extension, destination_extension = nil)
    current_convertify_ext = context["convertify_extension"]

    destination_extension = nil if destination_extension&.empty? != false

    # Infer the destination extension if not provided
    inferred_dst_ext =
      destination_extension ||
      current_convertify_ext ||
      ConvertHelper.infer_extension(context.template_name) ||
      ConvertHelper.infer_extension(context.registers[:page]["name"])

    result = ConvertHelper::find_converter(context, source_extension, inferred_dst_ext)

    if result.nil?
      raise Liquid::ArgumentError,
            "No converter available for '#{source_extension}'"
    elsif destination_extension && result.destination_extension != destination_extension
      raise Liquid::ArgumentError,
            "No converter available for '#{source_extension}' to '#{destination_extension}'"
    end
    result.converter.convert(context.stack do
      context["convertify_extension"] = source_extension
      render.call
    end)
  end
end
