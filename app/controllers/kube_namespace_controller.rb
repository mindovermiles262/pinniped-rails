class KubeNamespaceController < ApplicationController
    require 'kubeclient'

    def index
        @client = authenticate_to_cluster
        byebug
        @namespaces = @client.get_namespaces
        
    end

    private

    def authenticate_to_cluster
        # Returns a Kubeclient object authenticated to the cluster
        config = Kubeclient::Config.read('/Users/aduss/.kube/config')
        context = config.context
        ssl_options = context.ssl_options
        auth_options = context.auth_options
        Kubeclient::Client.new(
            context.api_endpoint, 'v1',
            ssl_options: ssl_options, auth_options: auth_options
        )
    end
end
