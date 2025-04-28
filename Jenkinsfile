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
                echo "Commit ID: ${commit_id}"
            }
        }
        stage('Image Build') {
            steps {
                echo "Copying Dockerfile and index.html to Minikube..."
                sh "minikube cp ${WORKSPACE}/Dockerfile minikube:/tmp/Dockerfile"
                sh "minikube cp ${WORKSPACE}/index.html minikube:/tmp/index.html"
                
                echo "Building Docker image with tag fleetman-webapp:${commit_id}..."
                sh "minikube ssh 'cd /tmp && docker build -t fleetman-webapp:${commit_id} .'"
                
                echo "Build complete"
                // Ignore errors during cleanup
                sh "minikube ssh 'rm -f /tmp/Dockerfile /tmp/index.html' || true"
            }
        }
        stage('Deploy') {
            steps {
                echo "Deploying to Minikube"
                // Update the image in the replicaset manifest
                sh "sed -i -r 's|richardchesterwood/k8s-fleetman-webapp-angular:release2|fleetman-webapp:${commit_id}|' ${WORKSPACE}/replicaset-webapp.yml"
                // Apply the manifests
                sh "kubectl apply -f ${WORKSPACE}/replicaset-webapp.yml"
                sh "kubectl apply -f ${WORKSPACE}/webapp-service.yml"
                sh "kubectl get all"
                echo "Deployment complete"
            }
        }
    }
}
