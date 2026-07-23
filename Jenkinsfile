pipeline {

    agent any

    parameters {
        booleanParam(
            name: 'autoApprove',
            defaultValue: false,
            description: 'Automatically apply Terraform without manual approval'
        )
    }

    environment {
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'demo-eks-cluster'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        KUBECTL_VERSION = 'v1.30.14'
    }

    stages {

        stage('Checkout') {
            steps {
                dir('terraform') {
                    git branch: 'main',
                        url: 'https://github.com/Urmilaa/Terraform-Jenkins1.git'
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
                        sh '''
                            aws sts get-caller-identity
                            terraform init
                        '''
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
                        sh '''
                            terraform plan -out=tfplan
                            terraform show -no-color tfplan > tfplan.txt
                        '''
                    }
                }
            }
        }

        stage('Approval') {

            when {
                expression {
                    return !params.autoApprove
                }
            }

            steps {

                script {

                    def plan = readFile('terraform/tfplan.txt')

                    input(
                        message: 'Approve Terraform Apply?',
                        parameters: [
                            text(
                                name: 'Terraform Plan',
                                defaultValue: plan,
                                description: 'Review Terraform execution plan'
                            )
                        ]
                    )
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

                        sh '''
                            terraform apply -input=false tfplan
                        '''
                    }
                }
            }
        }

        stage('Refresh kubeconfig') {

            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {

                    sh '''
                        mkdir -p /var/lib/jenkins/.kube

                        rm -f ${KUBECONFIG}

                        aws eks update-kubeconfig \
                            --region ${AWS_REGION} \
                            --name ${CLUSTER_NAME} \
                            --kubeconfig ${KUBECONFIG}

                        echo "===== Kubeconfig Endpoint ====="
                        grep server ${KUBECONFIG}
                    '''
                }
            }
        }

        stage('Install kubectl') {

            steps {

                sh '''
                    sudo curl -Lo /usr/local/bin/kubectl \
                    https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl

                    sudo chmod +x /usr/local/bin/kubectl

                    kubectl version --client
                '''
            }
        }

        stage('Verify Cluster') {

            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {

                    sh '''
                        export KUBECONFIG=${KUBECONFIG}

                        aws sts get-caller-identity

                        echo ""
                        echo "===== Cluster Info ====="
                        kubectl cluster-info

                        echo ""
                        echo "===== Nodes ====="
                        kubectl get nodes -o wide

                        echo ""
                        echo "===== Current Context ====="
                        kubectl config current-context
                    '''
                }
            }
        }

    }

    post {

        success {
            echo 'EKS Cluster created successfully.'
        }

        failure {
            echo 'Pipeline failed.'
        }

        always {
            cleanWs()
        }
    }
}
