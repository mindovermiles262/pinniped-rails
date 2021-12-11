class KubeNamespaceController < ApplicationController
    require 'kubeclient'

    def index
        @cluster = Kubernetes.new.connect
        @namespaces = @cluster.get_namespaces
    end
end
