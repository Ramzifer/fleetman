def commit_id
pipeline {
    agent any
    stages {
        stage('Preparation') {
            steps {
                checkout scm
                sh "git rev-parse --short HEAD > .git/commit-id"
                script {
                    commit_id = readFile('.git/commit-id').trim()
                }
            }
        }
        stage('Image Build') {
            steps {
                echo "BUILDING docker image..........."
                sh "minikube ssh 'docker build -t fleetman-webapp:${commit_id} ./'"
                echo 'build complete'
                // Skip Docker Hub push due to DNS issues
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying to Minikube'
                sh "sed -i -r 's|richardchesterwood/k8s-fleetman-webapp:release2|fleetman-webapp:${commit_id}|' /var/lib/jenkins/k8s-fleetman-deploy/replicaset-webapp.yml"
                sh 'kubectl apply -f /var/lib/jenkins/k8s-fleetman-deploy/replicaset-webapp.yml'
                sh 'kubectl apply -f /var/lib/jenkins/k8s-fleetman-deploy/webapp-service.yml'
                sh 'kubectl get all'
                echo 'deployment complete'
            }
        }
    }
}
