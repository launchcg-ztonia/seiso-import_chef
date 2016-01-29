# Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
# Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
# License:: Apache 2.0
class Seiso::ImportChef::Util::InvalidDocumentError < StandardError

  def initialize(message)
		super
	end
end
