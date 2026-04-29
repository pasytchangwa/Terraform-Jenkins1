pipeline {

    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
       
    }

  
    stages {

        stage('Checkout') {
            steps {
                dir('terraform') {
                    git branch: 'main', url: 'https://github.com/Urmilaa/Terraform-Jenkins1.git'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'   
                ]]) {
                    dir('terraform') {
                        sh 'aws sts get-caller-identity'
                        sh 'terraform init'
                    }
                }
            }
        }
          stage('Terraform Validate') {
            steps {
                dir('terraform') {
                sh 'terraform validate'
                }
            }
        }
        stage('Terraform Plan') {
            steps {                                
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir('terraform') {
                        sh 'terraform plan -out=tfplan'
                        sh 'terraform show -no-color tfplan > tfplan.txt'
                    }
                }
            }
        }

        stage('Approval') {

            when {
                not { equals expected: true, actual: params.autoApprove }
            }

            steps {
                script {
                    def plan = readFile 'terraform/tfplan.txt'

                    input message: "Do you want to apply the plan?",
                    parameters: [
                        text(name: 'Terraform Plan', defaultValue: plan, description: 'Review Terraform Plan')
                    ]
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                 withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir('terraform') {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }

        stage('Update kubeconfig') {
             steps {
                        withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    dir('terraform') {
                        sh 'aws eks --region us-east-1 update-kubeconfig --name demo-eks-cluster'
                    }
                }
            }
        }
        
        
    }
}
