class Kubernetes < ApplicationRecord
    require 'kubeclient'
    require 'faraday'
    require 'base64'

    def connect
        config = Kubeclient::Config.read(Dir.home + '/.kube/config')
        Kubeclient::Client.new(
            config.context.api_endpoint,
            'v1',
            ssl_options: config.context.ssl_options,
            auth_options: config.context.auth_options
        )
    end

    def get_sealed_secrets
        # Returns JSON Object of sealed secrets
        client = Kubernetes.new.connect
        token = client.auth_options[:bearer_token]
        api_endpoint = client.api_endpoint.to_s
        ca_cert = Kubernetes.new.get_current_ca_cert(Dir.home + "/.kube/config")

        url = api_endpoint + "s/bitnami.com/v1alpha1/namespaces/default/sealedsecrets"
        curl = Faraday.new(url, :ssl => {
            :ca_file => Dir.home + "/.kube/ca.crt"
        })
        resp = curl.get(url, {}, {
            "Authorization": "Bearer #{token}"
        })
        ActiveSupport::JSON.decode(resp.env.response_body)
    end

    protected

    def get_current_ca_cert(filepath)
        # Parses kubeconfig and returns Certificate Authority certificate. Also writes cert to $HOME/.kube/ca.crt
        config = Kubernetes.new.kube_config(filepath)
        current_context = config['current-context']

        # Get ARN of current cluster
        cluster_arn = ""
        config['contexts'].each do |context|
            cluster_arn = context['context']['cluster'] if context['name'] == current_context
        end

        # Get CA Data from cluster ARN
        ca_data_b64 = ""
        config['clusters'].each do |cluster|
            # cluster.name is the ARN of the cluster
            ca_data_b64 = cluster['cluster']['certificate-authority-data'] if cluster['name'] == cluster_arn
        end
        ca_cert = Base64.decode64(ca_data_b64)
        # I hate this so much but there is no option in Faraday to enter the certificate authority as a string
        File.open(Dir.home + "/.kube/ca.crt", "w") { |f| f.write ca_cert }
        ca_cert
    end

    def kube_config(filename)
        # Parses kubeconfig and returns hash
        if RUBY_VERSION >= '2.6'
            YAML.safe_load(File.read(filename), permitted_classes: [Date, Time])
        else
            YAML.safe_load(File.read(filename), [Date, Time])
        end
    end
end
