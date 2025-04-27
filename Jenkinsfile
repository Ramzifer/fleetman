pipeline {
    agent any
    stages {
        stage('Deploy to Minikube') {
            steps {
                sh '''
                kubectl apply -f /var/lib/jenkins/k8s-fleetman-deploy/replicaset-webapp.yml
                kubectl apply -f /var/lib/jenkins/k8s-fleetman-deploy/webapp-service.yml
                '''
            }
        }
    }
}
