module Seiso::ImportChef::Validators
  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Copyright:: Copyright (c) 2014-2016 Expedia, Inc.
  # License:: Apache 2.0
  class MachineValidator < BaseValidator

    def initialize
      @log = Seiso::ImportChef::Util::Logger.new "MachineValidator"
    end

    def validate(doc)
#      @log.info "Validating machines"
      validate_machines doc
    end

    private

    def validate_machines(doc)
      machine_name = doc['name']

      if machine_name.nil?
        error 'Machine document must contain a name field containing the machine name.'
      end
    end

  end
end
