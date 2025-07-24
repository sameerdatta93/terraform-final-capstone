properties([parameters(getParametersBasedOnBuild())])
pipeline {
    agent any 
    environment {
	TERRAFORM_VERSION="1.8.2" 
        DOCKERHUB_CREDS = 'sd-dockerhub-creds'
        VERSION = "2.0.${env.BUILD_NUMBER}"
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = ''
        LIFECYCLE = ""
        CREDENTIAL_ID = ""
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
						 stage("Region us-west-2") {
                    when {
                        expression {
                            return params.US_WEST_TWO
                        }
                    }

                    agent {
                                        docker { 
                                                image 'node:14-alpine'
                                                args '-e HOME=/tmp -e NPM_CONFIG_PREFIX=/tmp/.npm'
                                                reuseNode true
                                                }
                                        }
										
						 steps{
							script {
								ansiColor('xterm'){
									sh '''
										echo 'Inside Desploy Terraform';
										
										rm -rf /usr/local/bin/terraform
										wget https://releases.hashicorp.com/terraform/"$TERRAFORM_VERSION"/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
										unzip -o terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
										rm -rf terraform_*.zip
										rm -rf terraform_*.zip.*
										mv terraform /usr/local/bin/
										terraform --version
										aws --version
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

    paramList.add(booleanParam(name: 'US_EAST_ONE', defaultValue: true, description: 'select this checkbox to deploy in selected region \n NOTE: Selected Region will be primary region'))
    paramList.add(booleanParam(name: 'US_WEST_TWO', defaultValue: false, description: 'select this checkbox to deploy in selected region \n NOTE: Selected Region will be primary region'))
    if (env.BRANCH_NAME == 'master') {
            paramList.add(choice(name: 'TERRAFORM_ACTION', choices: ['plan','apply','switchover'], description: 'Choose apply to create new instances & destroy to destroy the existing instances'))
        } else{
            paramList.add(choice(name: 'TERRAFORM_ACTION', choices: ['plan','apply','destroy','switchover'], description: 'Choose apply to create new instances & destroy to destroy the existing instances, Select Switchove incase of primary region failure'))
        }
    
    return paramList
}
