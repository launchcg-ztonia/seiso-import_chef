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

    def initialize(chef_settings, seiso_settings)
      @chef = Chef::REST.new(
        "#{chef_settings['base_uri']}",
        "#{chef_settings['client_name']}",
        "#{chef_settings['signing_key']}")
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

            machine = @mapper.map_one(node_automatic)

            # FIXME Just setting this here for now since I'm not sure which node field the name corresponds to.
            # It's not exactly the FQDN (the case is different).
            machine['name'] = name
            page << machine
          rescue Net::HTTPServerException
            @log.error "Couldn't get #{name}"
            problem_nodes << {
              'name' => name,
              'reason' => "Couldn't get node from Chef server even though Chef server provided the name."
            }
          end
        end

        # FIXME This is not detecting some HTTP 500s that are happening. When this happens, the whole page fails, the
        # server returns an HTTP 500 (I think, anyway--need to confirm), and this call doesn't catch the error. Somehow
        # we need to surface these as problem nodes too, maybe indicating that the server didn't like them, as opposed
        # to not being able to read them from Chef server.
        @log.info "Flushing nodes to Seiso"
#        seiso.post_items('machines', page)
      end

      if problem_nodes.empty?
        @log.success "Successfully imported all machines"
      else
        @log.warn "Had problem importing #{problem_nodes.length} nodes:"
        @log.warn problem_nodes
      end

    end # method import_all
  end # class ImportChef
end # module Seiso
