pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                script{
                     // Checkout code from GitHub
                    def branchName = env.BRANCH_NAME
                    echo "Checking out code from branch: ${branchName}"
                    checkout([$class: 'GitSCM', 
                    branches: [[name: "${branchName}"]],  // Fetch code from all branches
                    userRemoteConfigs: [[url: 'https://github.com/AnirudhBadoni/AwsInfra.git']]]) 

                    // Get the latest commit hash
                    def commitId = sh(script: 'git rev-parse HEAD', returnStdout: true).trim().take(7)
                    env.IMAGE_TAG = "${branchName}-${commitId}"
                    echo "Docker image tag: ${env.IMAGE_TAG}"
                }
            }
        }
        stage ('Initialize Terraform and validate') {
            when { anyOf {branch "new-branch";changeRequest() } }
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding', 
                accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                credentialsId: 'AWS_ACCOUNT'
                ]]) {
                dir('infra'){
                sh 'terraform init -migrate-state'
                sh 'terraform fmt'
                sh 'terraform validate'
                }
                }
            }
            }
        stage ('Terraform plan'){
            when {
                branch 'new-branch'
            }
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding', 
                accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                credentialsId: 'AWS_ACCOUNT'
                ]]) {
                dir('infra'){
                sh 'terraform init'
                sh 'terraform plan'
                }
                }
            }
        }        
        stage ('Terraform plan & Action'){
            when {
                branch 'main'
            }
            steps {
                withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding', 
                accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                credentialsId: 'AWS_ACCOUNT'
                ]]) {
                dir('infra'){
                sh 'terraform init'
                sh 'terraform plan'
                sh 'terraform ${action} --auto-approve'
                }
                }
            }
        }
    }
}
