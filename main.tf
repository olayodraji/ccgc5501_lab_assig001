terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}


resource "aws_iam_role" "ccgc5501" {
  name = "terraform-user"

  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role_policy_attachment" "ccgc5501_attachment" {
  role       = aws_iam_role.ccgc5501.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ccgc5501_profile" {
  name = "ccgc5501_profile"
  role = aws_iam_role.ccgc5501.name
}

resource "aws_instance" "ccgc5501_instance" {
  ami           = "ami-02d7fd1c2af6eead0"
  instance_type = "t2.micro"
  
  iam_instance_profile = aws_iam_instance_profile.ccgc5501_profile.name

  tags = {
    Name = "ccgc5501instance"
  }
}

resource "aws_s3_bucket_policy" "ccgc5501_bucket_policy" {
  bucket = "ccgc5501-bucket"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ccgc5501.name}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::ccgc5501-bucket",
          "arn:aws:s3:::ccgc5501-bucket/*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}