pipeline {
    agent any

    environment {
        KUBECONFIG = "/var/jenkins_home/.kube/config"
    }

    stages {
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    if [ ! -f ./kubectl ]; then
                        curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                    fi

                    ./kubectl get nodes

                    ./kubectl apply -f k8s/deployment.yaml

                    ./kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }
}