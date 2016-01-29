class Seiso::ImportChef

  # Resolves item keys to their URIs.
  #
  # Author:: Willie Wheeler
  # Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
  # License:: Apache 2.0
  #
  class Util::ItemResolver

    def initialize(api)
      @log = Util::Logger.new "ItemResolver"
      @api = api
      @special_searches = {
        # http://ruby-journal.com/becareful-with-space-in-lambda-hash-rocket-syntax-between-ruby-1-dot-9-and-2-dot-0/
        'loadBalancers' => ->(k) { @api.loadBalancers.search.findByName(name: k) },
        'machines' => ->(k) { @api.machines.search.findByName(name: k) },
        'persons' => ->(k) { @api.persons.search.findByUsername(username: k) }
      }
    end

    # Returns the item URI, or nil if either key is nil or the item doesn't exist.
    def item_uri(type, key)
      return nil if key.nil?
      search = @special_searches[type]
      if search == nil
        item = @api.send(type).search.findByKey(key: key)
      else
        item = search.call key
      end
      begin
        return item.links.self.href
      rescue HyperResource::ClientError => e
        status = e.response.status
        body = e.response.body
        raise "Response error: status=#{status}, body=#{body}" unless status == 404
        @log.warn "#{type}/#{key} not found. Returning nil."
        return nil
      end
    end
  end
end

