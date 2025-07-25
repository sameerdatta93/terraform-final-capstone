properties([parameters(getParametersBasedOnBuild())])
pipeline {
    agent any 
    environment {
        DOCKERHUB_CREDS = 'sd-dockerhub-creds'
        VERSION = "2.0.${env.BUILD_NUMBER}"
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = ''
        LIFECYCLE = ""
        CREDENTIAL_ID = "aws-creds-dev"
    }

    stages {
        stage('Git Checkout') {
            steps {
                echo 'Retrieve source from github' 
                checkout scm
            }
        }
        stage ('Initializing Terraform Deployment')
        {
            parallel {
                stage ('Region us-east-1')
                { 
                    when {
					    expression {
						return params.US_EAST_ONE
						}
					}
					agent {
						docker { 
							image 'samdatta93/terraform-aws-cli:latest'                                     
							args '--entrypoint=""'
						}
					}
			
					steps{
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${CREDENTIAL_ID}"]]){
							script {
								if(TERRAFORM_ACTION == 'plan'){
									sh '''
									echo 'Inside Terraform plan';
									terraform --version
									pwd
									ls
									cd eks
									terraform init
									terraform plan
									'''
								} else if(TERRAFORM_ACTION == 'apply'){
								{
									sh '''
									echo 'Inside Terraform apply';
									terraform --version
									pwd
									ls
									cd eks
									terraform init
									terraform plan
									terraform apply --auto-approve
									'''
								} 
								else if(TERRAFORM_ACTION == 'destroy'){
								{
									sh '''
									echo 'Inside Terraform destroy';
									terraform --version
									pwd
									ls
									cd eks
									terraform init
									terraform plan
									terraform destroy --auto-approve
									'''
								} else 
								{
									sh '''
									echo "Please select appropriate option from the list"
									'''
								}
							}
						}                                
					}
                }
                stage("Region us-west-2") {
                    when {
                        expression {
                            return params.US_WEST_TWO
                        }
                    }
                    agent {
						docker { 
							image 'samdatta93/terraform-aws-cli:latest'                                     
							args '--entrypoint=""'
						}
					}
					steps{
						withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${CREDENTIAL_ID}"]]){
							script {
									sh '''
									echo 'Inside Desploy Terraform';
									terraform --version
									pwd
									ls
									cd eks
									terraform init
									terraform plan
									'''
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

def getParametersBasedOnBuild() {        
    def paramList = []

    paramList.add(booleanParam(name: 'US_EAST_ONE', defaultValue: true, description: 'select this checkbox to deploy in selected region'))
    paramList.add(booleanParam(name: 'US_WEST_TWO', defaultValue: false, description: 'select this checkbox to deploy in selected region'))
    if (env.BRANCH_NAME == 'master') {
            paramList.add(choice(name: 'TERRAFORM_ACTION', choices: ['plan','apply','switchover'], description: 'Choose apply to create new instances & destroy to destroy the existing instances'))
        } else{
            paramList.add(choice(name: 'TERRAFORM_ACTION', choices: ['plan','apply','destroy','switchover'], description: 'Choose apply to create new instances & destroy to destroy the existing instances, Select Switchove incase of primary region failure'))
        }
    
    return paramList
}
