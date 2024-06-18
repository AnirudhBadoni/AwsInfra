pipeline {
    agent any

    environment {
        TF_WORKSPACE = 'dev' // Define your Terraform workspace
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('On Commit') {
            when {
                branch pattern: "^(?!main\$).*", comparator: "REGEXP"
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS-CREDENTIALS']]) {
                    withEnv(['AWS_PROFILE=default']){
                    script {
                        def branchName = env.BRANCH_NAME
                        echo "Running Terraform commands on branch ${branchName}"
                        dir('infra'){
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform fmt'
                        sh 'terraform plan -out=plan.tfplan'
                        }
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
        }
    }

        stage('On Pull Request') {
            when {
                changeRequest()
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS-CREDENTIALS']]) {
                    withEnv(['AWS_PROFILE=default']){
                    script {
                        def prBranch = env.BRANCH_NAME
                        echo "Running Terraform commands on pull request branch ${prBranch}"
                        dir('infra'){
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform fmt'
                        sh 'terraform plan -out=pr-plan.tfplan'
                        }
                    }
                }
            }
        }
        }

        stage('On Merge to Main') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS-CREDENTIALS']]) {
                    withEnv(['AWS_PROFILE=default']){
                    script {
                        def mainBranch = env.BRANCH_NAME
                        echo "Running Terraform apply on main branch ${mainBranch}"
                        dir('infra'){
                        sh 'terraform init'
                        sh 'terraform validate'
                        sh 'terraform fmt'
                        sh 'terraform apply -auto-approve'
                        }
                    }
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
