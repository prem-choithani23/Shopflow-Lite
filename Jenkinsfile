pipeline {
    agent any

    environment {
        KUBECONFIG = "/var/jenkins_home/.kube/config"
    }

    stages {
        stage('Setup kubectl') {
            steps {
                sh '''
                    # Download kubectl to workspace
                    if [ ! -f ./kubectl ]; then
                        echo "Downloading kubectl..."
                        cd /tmp && curl -L "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl" -o kubectl
                        chmod +x kubectl
                        mv kubectl ${WORKSPACE}/
                        cd ${WORKSPACE}
                    fi
                    
                    echo "kubectl ready at: ${WORKSPACE}/kubectl"
                    ./kubectl version --client
                '''
            }
        }
        
        stage('Verify Kubernetes Access') {
            steps {
                sh '''
                    echo "Testing kubectl access with kubeconfig: ${KUBECONFIG}"
                    ./kubectl get nodes
                '''
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    echo "Deploying Shopflow to Kubernetes..."
                    ./kubectl apply -f k8s/deployment.yaml
                    ./kubectl apply -f k8s/service.yaml
                    
                    echo ""
                    echo "Deployment successful! Checking pod status..."
                    ./kubectl get pods -l app=shopflow
                '''
            }
        }
    }
    
    post {
        always {
            echo "Pipeline execution completed"
        }
        failure {
            echo "Deployment failed! Check kubeconfig and kubectl access"
        }
        success {
            echo "Shopflow successfully deployed to Kubernetes!"
        }
    }
}