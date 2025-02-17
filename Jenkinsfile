pipeline {
    agent any

    environment {
        BASE_DIR = "${env.WORKSPACE}"
        TERRAFORM_BIN = "/usr/bin/terraform"
    }

    stages {
        stage('Check Commit Message') {
            steps {
                script {
                    def commitMessage = sh(script: "git log -1 --pretty=%B", returnStdout: true).trim()
                    echo "Commit Message: ${commitMessage}"
                    sh """
                    echo '${commitMessage}' | npx commitlint --extends '@commitlint/config-conventional'
                    """
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
                        if (dirPath) {
                            echo "🔍 Running Terraform checks in directory: ${dirPath}"                        
                            sh """
                            cd ${dirPath}
                            ${TERRAFORM_BIN} fmt -check -recursive
			    ${TERRAFORM_BIN} init -backend=false
                            ${TERRAFORM_BIN} validate
                            """
                            publishChecks name: "Terraform Check in ${dirPath}", summary: "Terraform checks passed in ${dirPath}", conclusion: 'SUCCESS'
                        }
                    }
                }
            }
        }
    }

    post {
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
