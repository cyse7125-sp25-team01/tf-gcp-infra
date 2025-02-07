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

                    for (dir in directories) {
                        dir = dir.trim()
                        if (dir) {
                            echo "🔍 Running Terraform checks in directory: ${dir}"

                            dir("${dir}") {
                                stage("Terraform Checks in ${dir}") {
                                    steps {
                                        script {
                                            publishChecks name: "Terraform Check in ${dir}", summary: "Running Terraform fmt, init, and validate in ${dir}"

                                            // Run Terraform inside Docker without entrypoint
                                            sh """
                                            docker run --rm --entrypoint="" -v ${BASE_DIR}:/workspace -w /workspace/${dir} hashicorp/terraform:latest terraform fmt -check
                                            docker run --rm --entrypoint="" -v ${BASE_DIR}:/workspace -w /workspace/${dir} hashicorp/terraform:latest terraform init -backend=false
                                            docker run --rm --entrypoint="" -v ${BASE_DIR}:/workspace -w /workspace/${dir} hashicorp/terraform:latest terraform validate
                                            """

                                            publishChecks name: "Terraform Check in ${dir}", summary: "Terraform checks passed in ${dir}", conclusion: 'SUCCESS'
                                        }
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
