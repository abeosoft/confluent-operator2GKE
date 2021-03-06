#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "cp53-node" {
  name = "terraform-eks-cp53-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cp53-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.cp53-node.name}"
}

resource "aws_iam_role_policy_attachment" "cp53-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.cp53-node.name}"
}

resource "aws_iam_role_policy_attachment" "cp53-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.cp53-node.name}"
}

resource "aws_eks_node_group" "cp53" {
  cluster_name    = "${aws_eks_cluster.cp53.name}"
  node_group_name = "cp53"
  node_role_arn   = "${aws_iam_role.cp53-node.arn}"
  subnet_ids      = "${aws_subnet.cp53[*].id}"
  ami_type        = "AL2_x86_64"
  disk_size       = 50
  instance_types  = ["t2.xlarge"]

  scaling_config {
    desired_size = var.node_count
    max_size     = 16
    min_size     = 1
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cp53-node-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.cp53-node-AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.cp53-node-AmazonEC2ContainerRegistryReadOnly",
  ]

  tags = {
    Name = "terraform-eks-node-group-cp53"
    owner = "cmutzlitz@confluent.io"
  }

}
