pipeline {
    agent any
    environment {
        COMMIT_ID = "${GIT_COMMIT.take(7)}"
    }
    stages {
        stage('Preparation') {
            steps {
                git 'https://github.com/Ramzifer/fleetman.git'
                sh 'git clone https://github.com/Ramzifer/fleetman-position-tracker.git position-tracker'
            }
        }
        stage('Build Position Tracker') {
            steps {
                dir('position-tracker') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                dir('position-tracker') {
                    sh 'sonar-scanner -Dsonar.projectKey=fleetman-position-tracker -Dsonar.host.url=http://localhost:9000 -Dsonar.login=admin -Dsonar.password=admin'
                }
            }
        }
        stage('SonarQube Quality Gate') {
            steps {
                dir('position-tracker') {
                    sh 'sleep 10'
                    sh 'curl -u admin:admin http://localhost:9000/api/qualitygates/project_status?projectKey=fleetman-position-tracker > status.json'
                    sh 'cat status.json'
                    sh 'if grep -q \'"status":"ERROR"\' status.json; then exit 1; fi'
                }
            }
        }
        stage('Image Build for Webapp') {
            steps {
                sh "minikube cp ${WORKSPACE} /tmp/webapp"
                sh "minikube ssh 'sudo mkdir -p /tmp/webapp && sudo chmod -R 777 /tmp/webapp'"
                sh "minikube cp ${WORKSPACE}/index.html /tmp/webapp/index.html"
                sh "minikube cp ${WORKSPACE}/Dockerfile /tmp/webapp/Dockerfile"
                sh "minikube ssh 'cd /tmp/webapp && sudo docker build -t fleetman-webapp:${COMMIT_ID} .'"
            }
        }
        stage('Deploy Position Tracker') {
            steps {
                dir('position-tracker/k8s') {
                    sh 'kubectl apply -f deployment.yml'
                    sh 'kubectl apply -f service.yml'
                }
            }
        }
        stage('Deploy Webapp') {
            steps {
                sh "sed -i 's/fleetman-webapp:.*/fleetman-webapp:${COMMIT_ID}/' replicaset-webapp.yml"
                sh 'kubectl apply -f replicaset-webapp.yml'
                sh 'kubectl apply -f webapp-service.yml'
            }
        }
    }
}
