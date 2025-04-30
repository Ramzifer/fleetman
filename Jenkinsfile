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
                // Clone position-tracker if not present
                sh """
                if [ ! -d "position-tracker" ]; then
                    git clone https://github.com/DickChesterwood/fleetman-position-tracker.git position-tracker
                fi
                """
            }
        }
        stage('Build Position Tracker') {
            steps {
                dir('position-tracker') {
                    sh "mvn clean package -DskipTests"
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                dir('position-tracker') {
                    withSonarQubeEnv('SonarQube') {
                        sh """
                        sonar-scanner \
                          -Dsonar.projectKey=fleetman-position-tracker \
                          -Dsonar.projectName='Fleetman Position Tracker' \
                          -Dsonar.sources=src/main/java \
                          -Dsonar.java.binaries=target/classes
                        """
                    }
                }
            }
        }
        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Image Build for Webapp') {
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
        stage('Deploy Position Tracker') {
            steps {
                echo "Deploying Position Tracker to Minikube"
                sh "kubectl apply -f ${WORKSPACE}/../position-tracker-deployment.yml"
                sh "kubectl apply -f ${WORKSPACE}/../position-tracker-service.yml"
                sh "kubectl delete pod -l app=position-tracker || true"
            }
        }
        stage('Deploy Webapp') {
            steps {
                echo "Deploying Webapp to Minikube"
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
