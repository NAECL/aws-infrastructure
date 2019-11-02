# Had a really hard time sorting this out, cribbed from following articles, URLs
#
# https://gist.github.com/magnetikonline/6215d9e80021c1f8de12#getputdelete-access-to-specific-path-within-a-bucket
# https://www.reddit.com/r/aws/comments/685fn6/s3_policy_listobjects_denied/
# https://serverfault.com/questions/810890/aws-sync-between-s3-buckets-on-different-aws-accounts#811583
#

resource "aws_iam_instance_profile" "STANDARD_profile" {
  name  = "STANDARD_profile"
  role = "${aws_iam_role.STANDARD_role.name}"
}

resource "aws_iam_role" "STANDARD_role" {
  name               = "STANDARD_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "STANDARD_policy_S31" {
  name        = "STANDARD_policy_S31"
  role        = "${aws_iam_role.STANDARD_role.id}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "STANDARD_policy_S33" {
  name        = "STANDARD_policy_S33"
  role        = "${aws_iam_role.STANDARD_role.id}"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::backups.test.naecl.co.uk"
            ]
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::backups.test.naecl.co.uk/*"
            ]
        }
    ]
}
EOF
}
