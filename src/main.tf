module "infra" {
  count  = 1
  source = "./infra"

  AWS_REGION = "${var.AWS_REGION}"
}

module "k8s" {
  count  = 1
  source = "./k8s"
}
