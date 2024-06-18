pipeline {
    agent any

    environment {
        TF_WORKSPACE = 'dev' // Define your Terraform workspace
    }

    stages {
        stage('On Commit') {
            when {
                branch pattern: "^(?!main$).*", comparator: "REGEXP"
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS-CREDENTIALS']]) {
                    script {
                        def branchName = env.BRANCH_NAME
                        echo "Running Terraform commands on branch ${branchName}"

                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform fmt'
                        sh 'terraform plan -out=plan.tfplan'

                        // Optional: Run Checkov scan
                        try {
                            sh 'checkov -d .'
                        } catch (Exception e) {
                            echo 'Checkov scan failed, but proceeding with the pipeline.'
                        }
                    }
                }
            }
        }

        stage('On Pull Request') {
            when {
                changeRequest()
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        def prBranch = env.BRANCH_NAME
                        echo "Running Terraform commands on pull request branch ${prBranch}"

                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform fmt'
                        sh 'terraform plan -out=pr-plan.tfplan'
                    }
                }
            }
        }

        stage('On Merge to Main') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        def mainBranch = env.BRANCH_NAME
                        echo "Running Terraform apply on main branch ${mainBranch}"

                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform fmt'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
