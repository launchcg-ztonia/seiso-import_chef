class Seiso::ImportChef
  # Imports a machine document into Seiso
  #
  # Each Chef node represents a machine document. This importer compares the 
  # Seiso machines and will synchronize the machine lists.

  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Author:: Zaal Tonia (mailto:v-ztonia@expedia.com)
  # Copyright:: Copyright (c) 2016-2018 Expedia, Inc.
  # License:: Apache 2.0

  class Importers::MachineImporter < Importers::BaseImporter
    def initialize(api, rest_util, resolver)
      self.api = api
      self.rest_util = rest_util
      self.mapper = Mappers::ChefMachineMapper.new resolver
      self.repo_resource = api.machines.get

      @validator = Validators::MachineValidator.new
      @search_resource = api.machines.search.get
    end

    def import(doc)
      @validator.validate doc

      import_items([doc], {'dataCenter' => nil})
    end


    # Can't make these protected, because that prevents BaseImporter from seeing them.
#    protected

    # BaseImporter callback
    def to_search_params(doc_node, context)
      { 'name' => doc_node['name'] }
    end

    # BaseImporter callback
    def find_resource(search_params)
      @search_resource.findByName(name: search_params['name']).get
    end

    private

    def delete_orphans(doc_nodes, seiso_nodes)
      doc_node_names = doc_nodes.map { |doc_node| doc_node['name'] }
      seiso_nodes.each do |seiso_node|
        orphan = !doc_node_names.include?(seiso_node.name)
        if orphan
          params = { 'name' => seiso_node.name }
          rest_util.delete(seiso_node, params)
        end
      end
    end

  end
end
