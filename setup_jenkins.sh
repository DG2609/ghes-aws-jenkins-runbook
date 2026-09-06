#!/bin/bash
set -euxo pipefail

mkdir -p /root/jenkins-ghes-test/init.groovy.d

cat > /root/jenkins-ghes-test/Dockerfile <<'DOCKERFILE'
FROM jenkins/jenkins:lts-jdk17
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
DOCKERFILE

cat > /root/jenkins-ghes-test/plugins.txt <<'PLUGINS'
git:latest
github:latest
workflow-aggregator:latest
credentials-binding:latest
github-branch-source:latest
PLUGINS

cat > /root/jenkins-ghes-test/init.groovy.d/010-security.groovy <<'GROOVY1'
import jenkins.model.*
import hudson.security.*
import jenkins.install.*

def instance = Jenkins.instance
def user = System.getenv("JENKINS_ADMIN_USER") ?: "admin"
def pass = System.getenv("JENKINS_ADMIN_PASSWORD")

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(user, pass)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()
GROOVY1

cat > /root/jenkins-ghes-test/init.groovy.d/020-credential.groovy <<'GROOVY2'
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

def githubToken = System.getenv("GITHUB_TOKEN")
def githubUser = System.getenv("GITHUB_USERNAME") ?: "git"

def domain = Domain.global()
def store = Jenkins.instance.getExtensionList(
    'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
)[0].getStore()

def cred = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "github-pat",
    "GitHub PAT for access-key test",
    githubUser,
    githubToken
)
store.addCredentials(domain, cred)
GROOVY2

cat > /root/jenkins-ghes-test/init.groovy.d/030-create-job.groovy <<'GROOVY3'
import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

def jenkins = Jenkins.instance
def jobName = "ghes-access-key-test"

if (jenkins.getItem(jobName) == null) {
    def job = jenkins.createProject(WorkflowJob, jobName)
    def repoUrl = System.getenv("TEST_REPO_URL")
    def pipelineScript = """
pipeline {
  agent any
  triggers { githubPush() }
  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: '${repoUrl}', credentialsId: 'github-pat'
      }
    }
    stage('Verify') {
      steps {
        sh 'cat hello-from-claude.md'
        sh 'date'
      }
    }
  }
}
"""
    def flowDefinition = new CpsFlowDefinition(pipelineScript, true)
    job.definition = flowDefinition
    job.save()
}
GROOVY3

echo "=== Files written ==="
find /root/jenkins-ghes-test -type f

echo "=== Building image ==="
docker build -t ghes-jenkins-test /root/jenkins-ghes-test
