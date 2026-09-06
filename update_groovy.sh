#!/bin/bash
set -e
cat > /root/jenkins-ghes-test/init.groovy.d/030-create-job.groovy <<'GROOVY3'
import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

def jenkins = Jenkins.instance
def jobName = "ghes-access-key-test"

def job = jenkins.getItem(jobName)
if (job == null) {
    job = jenkins.createProject(WorkflowJob, jobName)
}

def repoUrl = System.getenv("TEST_REPO_URL")
def pipelineScript = """
pipeline {
  agent any
  triggers {
    githubPush()
    cron('* * * * *')
  }
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
job.definition = new CpsFlowDefinition(pipelineScript, true)
job.save()
GROOVY3

echo "=== verify written content ==="
cat /root/jenkins-ghes-test/init.groovy.d/030-create-job.groovy
