pipeline {
    agent any

    environment {
        TF_VERSION = "1.4.6"
        BASE_DIR = "${env.WORKSPACE}" // Base directory where the repository is cloned
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
                    sh 'terraform --version'
                    publishChecks name: 'Terraform Setup', summary: 'Terraform installed successfully', conclusion: 'SUCCESS'
                }
            }
        }

        stage('Terraform Checks for All Subdirectories') {
            steps {
                script {
                    // Identify all subdirectories containing Terraform code
                    def directories = sh(
                        script: "find ${BASE_DIR} -type d -not -path '*/.*'",
                        returnStdout: true
                    ).trim().split('\n')

                    // Iterate through each subdirectory
                    for (dir in directories) {
                        dir = dir.trim()
                        echo "Running Terraform checks in directory: ${dir}"

                        dir("${dir}") {
                            stage("Terraform Checks in ${dir}") {
                                steps {
                                    script {
                                        publishChecks name: "Terraform Check in ${dir}", summary: "Running Terraform fmt, init, and validate in ${dir}"
                                        
                                        // Run Terraform format check
                                        sh 'terraform fmt -check'

                                        // Initialize and validate Terraform
                                        sh '''
                                        terraform init
                                        terraform validate
                                        '''
                                        
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
