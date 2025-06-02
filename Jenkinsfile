pipeline {
    agent any
    environment {
        COMMIT_ID = "${GIT_COMMIT.take(7)}"
    }
    stages {
        stage('Preparation') {
            steps {
                git branch: 'main', url: 'https://github.com/Ramzifer/fleetman.git'
                // Remove existing position-tracker directory if it exists
                sh '''
                    if [ -d "position-tracker" ]; then
                        rm -rf position-tracker
                    fi
                    git clone https://github.com/Ramzifer/fleetman-position-tracker.git position-tracker
                '''
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
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh 'mvn sonar:sonar -Dsonar.projectKey=fleetman-position-tracker -Dsonar.host.url=http://localhost:9000 -Dsonar.login=$SONAR_TOKEN'
                    }
                }
            }
        }
        stage('SonarQube Quality Gate') {
            steps {
                dir('position-tracker') {
                    sh 'sleep 10'
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh "curl -H 'Authorization: Bearer $SONAR_TOKEN' http://localhost:9000/api/qualitygates/project_status?projectKey=fleetman-position-tracker > status.json"
                    }
                    sh 'cat status.json'
                    sh 'if grep -q \'"status":"ERROR"\' status.json; then exit 1; fi'
                }
            }
        }
        stage('Image Build for Webapp') {
            steps {
                dir('fleetman') {
                    sh 'eval $(minikube docker-env)'
                    sh "docker build -t fleetman-webapp:${COMMIT_ID} ."
                    sh 'eval $(minikube docker-env --unset)'
                }
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
# Temporary comment to trigger build
