data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "github_release" "default" {
  repository  = local.workload_repository_parts[1]
  owner       = local.workload_repository_parts[0]
  retrieve_by = "tag"
  release_tag = local.workload_version
}

data "aws_subnet" "private" {
  id = var.subnet_ids[0]
}

resource "null_resource" "trigger" {
  triggers = {
    release_id = data.github_release.default.id
  }

  provisioner "local-exec" {
    command = "${path.module}/bin/trigger -project-name=${var.workload_name}-source -source-version=${local.workload_version}"
  }

  depends_on = [
    aws_codebuild_project.deploy_functions,
    aws_codebuild_project.source,
    aws_codepipeline.codepipeline,
  ]
}
