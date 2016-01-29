class Seiso::ImportChef
  # Author:: Willie Wheeler
  # Copyright:: Copyright (c) 2014-2016 Expedia, Inc.
  # License:: Apache 2.0
  class Util::RestUtil

    def initialize
      @log = Util::Logger.new "RestUtil"
    end

    def get_or_nil(resource, description)
      begin
        return resource.get
      rescue HyperResource::ClientError => e
        status = e.response.status
        body = e.response.body
        raise "Response error: status=#{status}, body=#{body}" unless status == 404
        @log.warn "Resource #{description} not found. Returning nil."
        return nil
      end
    end

    def post(repo_resource, data, description)
      repo_resource_uri = repo_resource.links.self.href
      @log.info "POST #{repo_resource_uri} (#{description})"
      response = repo_resource.post data
      # TODO Read the status from the response if possible. [WLW]
      @log.info "  201 Created: #{response.href}"
#      response.href
      response
    end

    def put(resource, data, description)
      resource_uri = resource.links.self.href
      @log.info "PUT #{resource_uri} (#{description})"
      resource.put data
    end

    def delete(resource, description)
      resource_uri = resource.links.self.href
      @log.info "DELETE #{resource_uri} (#{description})"
      resource.delete
    end
  end
end

