class Seiso::ImportChef
  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Copyright:: Copyright (c) 2014-2016 Expedia, Inc.
  # License:: Apache 2.0
  class Validators::BaseValidator
    # Raises an InvalidDocumentError with the given message.
    # TODO Move to module method instead?
    def error(msg)
      fail Util::InvalidDocumentError.new msg
    end
  end
end
