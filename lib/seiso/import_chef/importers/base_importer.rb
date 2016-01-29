require 'hyper_resource'

class Seiso::ImportChef

  class Importers::BaseImporter
    def import_items(doc_items, context)
      doc_items.each { |doc_item| import_item(doc_item, context) }
    end

    # Imports a single document item into Seiso.
    def import_item(doc_item, context)
      data = mapper.map(doc_item, context)
      search_params = to_search_params(doc_item, context)

      begin
        resource = find_resource search_params
        rest_util.put(resource, data, search_params)
        resource.links.self.href
      rescue HyperResource::ClientError => e
        status = e.response.status
        body = e.response.body
        fail "Response error: status=#{status}, body=#{body}" unless status == 404
        # Seiso API returns the created resource in the response body. Capture.

        resource = rest_util.post(repo_resource, data, search_params)
      end

      if respond_to?(:import_children_of)
        new_context = respond_to?(:context_for) ? context_for(resource, context)_ : {}
        import_children_of(doc_Item, new_context)
      end

      resource.href
    end

    protected

    attr_accessor :api
    attr_accessor :rest_util
    attr_accessor :mapper
    attr_accessor :repo_resource

  end
end
