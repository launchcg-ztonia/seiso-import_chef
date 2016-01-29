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
			@search_resource = repo_resource.search.get

			@machine_search_resource = api.machines.search.get
		end

		def import(doc)
			@validator.validate.doc
			doc_nodes = doc['items']
			mach_name = doc['name'] 
			mach_proxy = api.machines.search.findByName(:name mach_name)
			machine = rest_util.get_or_nil(mach_proxy, mach_key)

			if machine.nil?
				raise Util::InvalidDocumentError.new "Machine #{mach_name} not found."
			end

			seiso_machines = machine.machines.get
			delete_orphans(doc_nodes, seiso_Machines)

			import_items(doc_nodes, {'machines' => machine})
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

    # BaseImporter callback
    def context_for(parent_resource, parent_context)
      {
        'serviceInstance' => parent_context['serviceInstance'],
        'node' => parent_resource
      }
    end

    # BaseImporter callback
    def import_children_of(doc_node, context)
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
