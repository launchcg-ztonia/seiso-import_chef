require 'hyper_resource'

class Seiso::ImportChef
  # Imports a machine document into Seiso
  #
  # Each Chef node represents a machine document. This importer compares the 
  # Seiso machines and will synchronize the machine lists.

  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Author:: Zaal Tonia (mailto:v-ztonia@expedia.com)
  # Copyright:: Copyright (c) 2016-2018 Expedia, Inc.
  # License:: Apache 2.0

  class Importers::MachineImporter
    def initialize(api, rest_util, resolver)
      self.api = api
      self.rest_util = rest_util
      self.mapper = Mappers::ChefMachineMapper.new resolver
      self.repo_resource = api.machines.get

      @validator = Validators::MachineValidator.new
      @search_resource = api.machines.search.get
    end
    
    def import(doc_items)
      @validator.validate doc
      doc_items.each { |doc_item| import_item(doc_item, context) }
    end

    # Imports a single document item into Seiso.
    def import_item(doc_item, context)
      data = mapper.map(doc_item, context)
      search_params = { 'name' => doc_item['name'] }

      begin
        resource = @search_resource.findByName(name: search_params['name']).get
        rest_util.put(resource, data, search_params)
        resource.links.self.href
      rescue HyperResource::ClientError => e
        status = e.response.status
        body = e.response.body
        fail "Response error: status=#{status}, body=#{body}" unless status == 404
        # Seiso API returns the created resource in the response body. Capture.

        resource = rest_util.post(repo_resource, data, search_params)
      end

      resource.href
    end

    private

    attr_accessor :api
    attr_accessor :rest_util
    attr_accessor :mapper
    attr_accessor :repo_resource

  end
end
