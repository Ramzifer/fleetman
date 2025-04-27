pipeline {
    agent any
    stages {
        stage('Deploy to Minikube') {
            steps {
                sh '''
                kubectl apply -f ~/k8s-fleetman-deploy/replicaset-webapp.yml
                kubectl apply -f ~/k8s-fleetman-deploy/webapp-service.yml
                '''
            }
        }
    }
}
