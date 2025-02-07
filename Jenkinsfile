pipeline {
    agent any

    environment {
        BASE_DIR = "${env.WORKSPACE}"
    }

    stages {
        stage('Checkout Repository') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Set up Terraform') {
            steps {
                script {
                    publishChecks name: 'Terraform Setup', summary: 'Checking Terraform installation'

                    // Run Terraform inside Docker and disable the entrypoint
                    sh 'docker run --rm --entrypoint="" hashicorp/terraform:latest terraform --version'

                    publishChecks name: 'Terraform Setup', summary: 'Terraform installed successfully', conclusion: 'SUCCESS'
                }
            }
        }

        stage('Terraform Checks for All Subdirectories') {
            steps {
                script {
                    def directories = sh(
                        script: "find ${BASE_DIR} -type d -not -path '*/.*' -not -path '${BASE_DIR}'",
                        returnStdout: true
                    ).trim().split('\n')

                    for (dirPath in directories) {
                        dirPath = dirPath.trim()
                        if (dirPath) { // Ensure it's a valid directory
                            echo "🔍 Running Terraform checks in directory: ${dirPath}"

                            // Ensure we use `dir()` correctly within the steps block
                            stage("Terraform Checks in ${dirPath}") {
                                steps {
                                    script {
                                        publishChecks name: "Terraform Check in ${dirPath}", summary: "Running Terraform fmt, init, and validate in ${dirPath}"

                                        sh """
                                        docker run --rm --entrypoint="" -v ${BASE_DIR}:/workspace -w /workspace/${dirPath} hashicorp/terraform:latest terraform fmt -check
                                        docker run --rm --entrypoint="" -v ${BASE_DIR}:/workspace -w /workspace/${dirPath} hashicorp/terraform:latest terraform init -backend=false
                                        docker run --rm --entrypoint="" -v ${BASE_DIR}:/workspace -w /workspace/${dirPath} hashicorp/terraform:latest terraform validate
                                        """

                                        publishChecks name: "Terraform Check in ${dirPath}", summary: "Terraform checks passed in ${dirPath}", conclusion: 'SUCCESS'
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/*.tf', fingerprint: true
        }
        failure {
            script {
                publishChecks name: 'Terraform Pipeline', summary: 'Terraform validation failed', conclusion: 'FAILURE'
            }
            echo '❌ Terraform validation failed!'
        }
        success {
            script {
                publishChecks name: 'Terraform Pipeline', summary: 'All Terraform checks passed', conclusion: 'SUCCESS'
            }
            echo '✅ Terraform validation passed!'
        }
    }
}
