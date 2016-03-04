require "minitest/autorun"
require "seiso/import_chef/chef_machine_mapper"

# Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
# Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
# License:: Apache 2.0

class TestChefMachineMapper < MiniTest::Unit::TestCase

  def setup
    @mapper = Seiso::ImportChef::ChefMachineMapper.new
    @chef_node = {
      "fqdn" => "my-fqdn",
      "hostname" => "my-hostname",
      "domain" => "my-domain",
      "ipaddress" => "1.2.3.4",
      "macaddress" => "abcdef123456",
      "platform" => "aws",
      "platform_version" => "2.0",
      "os" => "linux",
      "os_version" => "3.0",
      "kernel" => {
        "os_info" => {
          "serial_number" => "CABBAGE"
        }
      }
    }
  end

  def test_map_all
    chef_nodes = [ @chef_node ]
    seiso_machines = @mapper.map chef_nodes
    assert_equal(chef_nodes.length, seiso_machines.length)
  end

  def test_map_all_nil
    assert_nil(@mapper.map nil)
  end

  def test_map_one
    @seiso_machine = @mapper.map_one @chef_node
    assert_equal(@chef_node["fqdn"], @seiso_machine["fqdn"])
    assert_equal(@chef_node["hostname"], @seiso_machine["hostname"])
    assert_equal(@chef_node["domain"], @seiso_machine["domain"])
    assert_equal(@chef_node["ipaddress"], @seiso_machine["ipAddress"])
    assert_equal(@chef_node["macaddress"], @seiso_machine["macAddress"])
    assert_equal(@chef_node["platform"], @seiso_machine["platform"])
    assert_equal(@chef_node["platform_version"], @seiso_machine["platformVersion"])
    assert_equal(@chef_node["os"], @seiso_machine["os"])
    assert_equal(@chef_node["os_version"], @seiso_machine["osVersion"])
    assert_equal(@chef_node["kernel"]["os_info"]["serial_number"].downcase, @seiso_machine["serialNumber"])
  end

  def test_map_one_nil
    assert_nil(@mapper.map_one nil)
  end

  def test_map_one_cleanup
    chef_node = @chef_node.merge({
      "fqdn" => "   MY-FQDN   ",
      "ipaddress" => " 1.2.3.4  "
    })
    seiso_machine = @mapper.map_one chef_node
    assert_equal("my-fqdn", seiso_machine["fqdn"])
    assert_equal("1.2.3.4", seiso_machine["ipAddress"])
  end
end
