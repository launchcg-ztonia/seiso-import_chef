require 'chef/node'
require 'chef/rest'
require 'hyper_resource'
require 'require_all'
require_rel './import_chef'

# Seiso namespace module
module Seiso

  # Imports Chef nodes into Seiso as Seiso machines.
  #
  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
  # License:: Apache 2.0
  class ImportChef

    # Batch size for putting nodes into Seiso.
    PAGE_SIZE = 20
    
    def self.build(chef_settings, seiso3_settings)
      loader = Chef::REST.new(
        "#{chef_settings['base_uri']}",
        "#{chef_settings['client_name']}",
        "#{chef_settings['signing_key']}")
      v3_api = HyperResource.new(
        root: seiso3_settings['base_uri'],
        headers: {
          'Accept' => 'application/hal+json',
          'Content-Type' => 'application/hal+json'
        },
        auth: {
          basic: [ seiso3_settings['username'], seiso3_settings['password'] ]
        }
      )
      resolver = Util::ItemResolver.new v3_api
      rest_util = Util::RestUtil.new
      importer = Importers::MachineImporter.new(v3_api, rest_util, resolver)

      new(loader, importer)
      
    end

    def initialize(loaders, importer)
      @chef = loaders
      @importer = importer
      @mapper = Seiso::ImportChef::ChefMachineMapper.new
      @log = Util::Logger.new "ImportChef"
    end

    # Imports all nodes from the Chef server into Seiso.
    def import_all
      nodes = @chef.get_rest "/nodes"
      node_names = nodes.keys.sort!
      @log.info node_names

      slices = node_names.each_slice(PAGE_SIZE).to_a
      node_count = 0
      problem_nodes = []
      slices.each_with_index do |slice, page_index|
        @log.info "Building page #{page_index + 1} (total_nodes=#{node_names.length}, page_size=#{PAGE_SIZE})"
        page = []
        slice.each do |name|
          # name is case-sensitive in Chef, so we can't just downcase it
          node_count += 1
          @log.info "Getting node #{node_count} of #{node_names.length}: #{name}"
          begin
            node = @chef.get_rest "/nodes/#{name}"
            node_automatic = node.automatic

            # Have observed this. Need to decide whether to handle default/override/etc.
            if node_automatic.empty?
              @log.warn "Node #{name} has no automatic attributes"
              problem_nodes << {
                'name' => name,
                'reason' => "Node has no automatic attributes."
              }
              next
            end

            # FIXME Just setting this here for now since I'm not sure which node field the name corresponds to.
            # It's not exactly the FQDN (the case is different).
            node_automatic['name'] = name
            # page << machine
            import_one(node_automatic)

          rescue Net::HTTPServerException
            @log.error "Couldn't get #{name}"
            problem_nodes << {
              'name' => name,
              'reason' => "Couldn't get node from Chef server even though Chef server provided the name."
            }
          end
        end

      end

      if problem_nodes.empty?
        @log.success "Successfully imported all machines"
      else
        @log.warn "Had problem importing #{problem_nodes.length} nodes:"
        @log.warn problem_nodes
      end

    end # method import_all

    def import_one(doc)
      # FIXME This is not detecting some HTTP 500s that are happening. When this happens, the whole page fails, the
      # server returns an HTTP 500 (I think, anyway--need to confirm), and this call doesn't catch the error. Somehow
      # we need to surface these as problem nodes too, maybe indicating that the server didn't like them, as opposed
      # to not being able to read them from Chef server.
      @log.info "Importing machine #{doc.name}"
      begin
        @importer.import doc
          return true
      rescue Exception => e
        @log.error "Failed to import machine #{doc.name}: #{e.message}"
          raise e
      end
    end # method import_machine
  end # class ImportChef

end # module Seiso
