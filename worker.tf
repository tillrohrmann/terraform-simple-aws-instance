provider "aws" {
  region     = "${var.region}"
}

output "Worker Node public IP" {
  value = "${aws_instance.worker.public_ip}"
}

output "Worker private DNS" {
  value = "${aws_instance.worker.private_dns}"
}

resource "aws_key_pair" "worker" {
  key_name   = "worker_${var.run_id}"
  public_key = "${file("worker_id_rsa.pub")}"
}

resource "aws_security_group" "worker" {
  name_prefix = "aws_worker_"
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

resource "aws_instance" "worker" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.worker.key_name}"
  vpc_security_group_ids = ["${aws_security_group.worker.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.default.name}"

  provisioner "file" {
    connection {
      agent       = false
      private_key = "${file("worker_id_rsa")}"
      user        = "admin"
    }
    source      = "./worker_id_rsa"
    destination = "/home/admin/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      private_key = "${file("worker_id_rsa")}"
      user        = "admin"
    }
    inline = [
      "chmod 600 /home/admin/.ssh/id_rsa",
      "sudo apt-get -y -q update",
      "sudo apt-get -y -q install software-properties-common curl screen gnupg2 ca-certificates apt-transport-https openjdk-8-jre-headless ca-certificates-java openjdk-8-jdk libjna-java git gnuplot wget vim maven",
      "sudo update-java-alternatives --jre-headless --jre --set java-1.8.0-openjdk-amd64",
      "wget https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py",
      "sudo pip install awscli --upgrade",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get -y -q install docker-ce=17.03.3~ce-0~debian-stretch",
      "sudo usermod -a -G docker admin",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.12.2/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/",
      "curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.29.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/",
      "sudo minikube start --vm-driver=none",
      "sudo mv /root/.kube $HOME/.kube && sudo chown -R $USER $HOME/.kube && sudo chgrp -R $USER $HOME/.kube",
      "sed -i -e 's^root/^home/admin/^' $HOME/.kube/config",
      "sudo mv /root/.minikube $HOME/.minikube && sudo chown -R $USER $HOME/.minikube && sudo chgrp -R $USER $HOME/.minikube",
      "minikube update-context"
    ]
  }

  root_block_device {
    volume_size           = "${var.worker_root_volume_size}"
    volume_type           = "gp2"
    delete_on_termination = true
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
  name = "worker_${var.run_id}"
}
