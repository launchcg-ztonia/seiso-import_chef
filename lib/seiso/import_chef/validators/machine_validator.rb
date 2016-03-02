module Seiso::ImportChef::Validators
  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Copyright:: Copyright (c) 2014-2016 Expedia, Inc.
  # License:: Apache 2.0
  class MachineValidator
    # Raises an InvalidDocumentError with the given message.

    def initialize
      @log = Seiso::ImportChef::Util::Logger.new "MachineValidator"
    end

    def validate(doc)
      if doc.is_a?(Array)
        doc.each { |doc_item| validate_machine(doc_item) }
      else
        validate_machine(doc)
      end
      
    end
    
    def error(msg)
      fail Util::InvalidDocumentError.new msg
    end

    private

    def validate_machine(doc)
      machine_name = doc['name']

      if machine_name.nil?
        error 'Machine document must contain a name field containing the machine name.'
      end
    end

  end
end
