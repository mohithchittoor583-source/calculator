pipeline {

    agent any
 
    environment {

        FRONTEND_DIR = "frontend"

        BACKEND_DIR = "backend"

        DEPLOY_DIR = "/var/www/html"

    }
 
    stages {
 
        stage('Checkout Source Code') {

            steps {

                echo 'Checking out source code...'

                checkout scm

            }

        }
 
        stage('Install Frontend Dependencies') {

            steps {

                dir("${FRONTEND_DIR}") {

                    sh 'npm install'

                }

            }

        }
 
        stage('Build React Application') {

            steps {

                dir("${FRONTEND_DIR}") {

                    sh 'npm run build'

                }

            }

        }
 
        stage('Deploy React to Nginx') {

            steps {

                sh "sudo rm -rf ${DEPLOY_DIR}/*"

                sh "sudo cp -r ${FRONTEND_DIR}/build/* ${DEPLOY_DIR}/"

            }

        }
 
        stage('Install Backend Dependencies') {

            steps {


                    sh '''

                        python3 -m venv venv || true

                        . venv/bin/activate

                        pip install --upgrade pip

                        pip install -r requirements.txt

                    '''

                }

            }

        }
 
        stage('Restart Flask Application') {

            steps {

                sh '''

                    sudo systemctl restart flask || true

                '''

            }

        }
 
    }
 
    post {
 
        success {

            echo 'Pipeline executed successfully.'

        }
 
        failure {

            echo 'Pipeline execution failed.'

        }
 
        always {

            cleanWs()

        }

    }

}
 
