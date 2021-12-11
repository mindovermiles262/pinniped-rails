class Kubernetes < ApplicationRecord
    require 'kubeclient'
    require 'faraday'

    def connect
        config = Kubeclient::Config.read('/Users/aduss/.kube/config')
        Kubeclient::Client.new(
            config.context.api_endpoint,
            'v1',
            ssl_options: config.context.ssl_options,
            auth_options: config.context.auth_options
        )
    end

    def get_sealed_secrets
        client = Kubernetes.new.connect
        token = client.auth_options[:bearer_token]
        api_endpoint = client.api_endpoint.to_s
        url = api_endpoint + "s/bitnami.com/v1alpha1/namespaces/default/sealedsecrets"
        curl = Faraday.new(url, :ssl => {
            :ca_file => "/Users/aduss/code/kubernetes/kube-curl/ca.crt"
        })
        resp = curl.get(url, {}, {
            "Authorization": "Bearer #{token}"
        })
        ActiveSupport::JSON.decode(resp.env.response_body)
    end
end
