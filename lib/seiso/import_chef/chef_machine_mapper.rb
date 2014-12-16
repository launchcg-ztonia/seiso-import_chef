# Seiso namespace module
module Seiso
  
  # Maps Chef nodes to Seiso machines.
  # 
  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Copyright:: Copyright (c) 2014-2015
  # License:: Apache 2.0
  
  class ChefMachineMapper
    
    # Maps a list of Chef nodes to a list of Seiso machines.
    def map_all(chef_nodes)
      return nil if chef_nodes.nil?
      seiso_machines = []
      chef_nodes.each do |n|
        seiso_machines << map_one(n)
      end
      seiso_machines
    end
    
    def map_one(chef_node)
      return nil if chef_node.nil?
      {
        # FIXME Not sure which field Chef uses as the key here, so we'll just set that externally for now.
        #      "name" => cleanup(chef_node["name"]),
        "fqdn" => cleanup(chef_node["fqdn"]),
        "hostname" => cleanup(chef_node["hostname"]),
        "domain" => cleanup(chef_node["domain"]),
        
        # TODO For the nodes so far, this is a single IP address. Not sure whether Chef supports multiple IPv4 addresses,
        # or what it returns in that case. Need to look into it.
        "ipAddress" => cleanup(chef_node["ipaddress"]),
        
        # FIXME Commenting this out for now, as it generates arrays where Seiso expects a single value. Not sure why
        # Chef uses a single value for IPv4 but an array for IPv6.
        #      "ip6Address" => cleanup(chef_node["ip6address"]),
        
        "macAddress" => cleanup(chef_node["macaddress"]),
        "platform" => cleanup(chef_node["platform"]),
        "platformVersion" => cleanup(chef_node["platform_version"]),
        "os" => cleanup(chef_node["os"]),
        "osVersion" => cleanup(chef_node["os_version"])
      }
    end
    
    private
    
    def cleanup(s)
      s.nil? ? nil : s.strip.downcase
    end
  end
end
