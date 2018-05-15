provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  assume_role {
    role_arn = "${var.role_arn}"
  }
}

output "Control Node public IP" {
  value = "${aws_instance.control.public_ip}"
}

resource "aws_security_group" "control" {
  name_prefix = "jepsen_control_"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "control" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.control.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.default.name}"

  provisioner "file" {
    connection {
      user = "admin"
    }
    source      = "./control-node-key"
    destination = "/home/admin/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    connection {
      user = "admin"
    }
    inline = [
      "chmod 600 /home/admin/.ssh/id_rsa",
      "sudo apt-get -y -q update",
      "sudo apt-get -y -q install software-properties-common curl screen",
      "sudo apt-get install -y -t jessie-backports openjdk-8-jre-headless ca-certificates-java",
      "sudo apt-get install -qqy openjdk-8-jdk libjna-java git gnuplot wget vim maven",
      "wget https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py",
      "sudo pip install awscli --upgrade"
    ]
  }
}

resource "aws_iam_role" "default" {
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

resource "aws_iam_instance_profile" "default" {
  role = "${aws_iam_role.default.name}"
}
