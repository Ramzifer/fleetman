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
                echo "Creating tarball of build files..."
                sh "cd /var/lib/jenkins/.jenkins/workspace/fleetman-deployment && tar -czf build-files.tar.gz Dockerfile index.html"
                echo "Copying tarball to Minikube..."
                sh "minikube cp /var/lib/jenkins/.jenkins/workspace/fleetman-deployment/build-files.tar.gz minikube:/tmp/build-files.tar.gz"
                echo "Extracting tarball in Minikube..."
                sh "export MINIKUBE_HOME=/var/lib/jenkins/.minikube && minikube ssh 'tar -xzf /tmp/build-files.tar.gz -C /tmp'"
                echo "BUILDING docker image with tag fleetman-webapp:${commit_id}..."
                sh "export MINIKUBE_HOME=/var/lib/jenkins/.minikube && minikube ssh \"cd /tmp && docker build -t fleetman-webapp:${commit_id} .\""
                echo 'build complete'
                sh "export MINIKUBE_HOME=/var/lib/jenkins/.minikube && minikube ssh 'rm -f /tmp/build-files.tar.gz /tmp/Dockerfile /tmp/index.html'"
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
