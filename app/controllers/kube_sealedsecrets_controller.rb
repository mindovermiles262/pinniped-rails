class KubeSealedsecretsController < ApplicationController
    require 'kubeclient'

    def index
        @secrets = Kubernetes.new.get_sealed_secrets['items']
    end
end
