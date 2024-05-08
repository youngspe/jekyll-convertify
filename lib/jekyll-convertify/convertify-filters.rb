module Jekyll; module ConvertifyFilters
  def convertify(input, source_extension, destination_extension = nil)
    Convertify.convert(@context, lambda { input }, source_extension, destination_extension)
  end
end; end
