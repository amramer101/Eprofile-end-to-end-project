resource "aws_codeartifact_domain" "vprofile_domain" {
  domain = "vprofile-domain"
}

resource "aws_codeartifact_repository" "vprofile_repo" {
  repository = "vprofile-repo"
  domain     = aws_codeartifact_domain.vprofile_domain.domain

  external_connections {
    external_connection_name = "public:maven-central"
  }
}