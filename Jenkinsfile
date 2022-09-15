pipeline {
    agent any
     environment {
        def name = "my name"
        def pwdv = "suresh"
        def branch="main"
    }
    parameters {
        string(name: 'STRING_VARIABLE', defaultValue: 'TestTrainer', description: 'Who should I say hello to?')
        text(name: 'BIOGRAPHY', defaultValue: '', description: 'Enter some information about the person')
        booleanParam(name: 'TOGGLE', defaultValue: true, description: 'Toggle this value')
        choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something')
        password(name: 'PASSWORD', defaultValue: 'SECRET', description: 'Enter a password')       
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Hello') {
            steps {
                echo 'Hello World'
                 git branch: "${branch}", url: 'https://github.com/sureshsuriking/project12.git'
                
            }
        }
        stage('Gmkdir') {
            steps {
                sh "mkdir -p abc/ghi/xyz"
                // timeout(time: 10, unit: 'SECONDS') {
                //     sleep 20
                // }
            }
        } 
        stage('terraform'){
	    steps{
		  sh "terraform init"
		  sh "terraform plan"
		  sh "terrafomr apply --auto-approve"
		  sh "terraform destroy"
	          }   
	    }
        stage('Hi') {
            steps {
                dir('abc') {
                    dir('ghi') {
                        dir('xyz') {
                            sh("touch fffffff.txt")
                        }
                    }
                }
                dir('abc/ghi/xyz') {
                   sh("touch ttttttttttt.txt")
                }
                echo 'Hello World'
                dir('abc/ghi') {
                  deleteDir()
                }
                timestamps {
                    echo "asdasd"
                }
            }
        }
         stage('Variable Initialization') {
            steps {
                script {
                    sh("echo ${name}")
                    writeFile file: 'test-write-file', text: 'asdasdasdasdasd'
                }
            }
        }
       
        stage('Loop') {
            steps {
                echo 'Hello World'

                script {
                    def browsers = ['chrome', 'firefox']
                    for (int i = 0; i < browsers.size(); ++i) {
                        echo "Testing the ${browsers[i]} browser"
                    }
                }
            }
        }
         
	    
    }
}
