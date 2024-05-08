module Convertify
  def self.infer_extension(name)
    ext = File.extname(name)
    return ext unless ext.empty?
    return nil if path.empty?
    name
  end

  def self.convert(context, render, source_extension, destination_extension = nil)
    # Get the site's converters
    converters = context.registers[:site].converters
    destination_is_explicit = !!destination_extension && !destination_extension.empty?
    current_convertify_ext = context["convertify_extension"]

    # Infer the destination extension if not provided
    unless destination_is_explicit
      destination_extension = current_convertify_ext || self.infer_extension(context.registers[:page]["name"])
    end

    # If source and destination extensions are the same, return input as-is
    return render.call if source_extension == destination_extension

    context.stack do
      context["convertify_extension"] = source_extension

      if destination_extension
        # Find the converter for the given source and destination extensions
        converter = converters.find { |c|
          !c.is_a?(Jekyll::Converters::Identity) &&
            c.matches(source_extension) &&
            c.output_ext(source_extension) == destination_extension
        }

        return converter.convert(render.call) if converter

        if destination_is_explicit
          raise ArgumentError, "No converter available for '#{source_extension}' to '#{destination_extension}'"
        end
      end

      # Find any converter for the given source extension
      converter = converters.find { |c|
        c.matches(source_extension)
      }

      return converter.convert(input) if converter

      raise ArgumentError, "No converter available for source extension '#{source_extension}'"
    end
  end
end
