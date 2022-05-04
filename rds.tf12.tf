# RDS-Related-Config-Issues

#######################################################
# VPC & Subnet
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}

#######################################################

# MarioDB RDS
resource "aws_db_instance" "iac-apsouth1-rds-mariodb" {
  allocated_storage               = 10
  engine                          = "mariadb"
  engine_version                  = "10.2.21"
  instance_class                  = "db.t2.micro"
  identifier                      = "iac-apsouth1-rds-mariodb" 
  db_name                         = "mariodb"
  password                        = "password"
  username                        = "admin"
  final_snapshot_identifier       = "iac-apsouth1-rds-mariodb-snapshot"
  skip_final_snapshot             = "true"
  multi_az                        = false
  port                            = 3306
  storage_encrypted               = false
  publicly_accessible             = true
  deletion_protection             = false
  tags = {
      Name        = "iac-apsouth1-rds-mariodb"
    }
}


# #######################################################

#### MYSQL RDS is publicly accessible
# Security group
resource "aws_security_group" "apsouth1-rds-mysqlopentoall" {
  name        = "apsouth1-rds-opentoall"
  vpc_id      = aws_vpc.apsouth1-ec2-vpc1.id
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "iac-apsouth1-rds-mysql" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "iac-apsouth1-rds-mysql" 
  db_name              = "mysqldb"
  username             = "root"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = "true"
  vpc_security_group_ids = ["${aws_security_group.apsouth1-rds-mysqlopentoall.id}"]
  storage_encrypted = "false"
  final_snapshot_identifier = "iac-apsouth1-rds-mysql-snapshot"
  skip_final_snapshot = "true" 
  tags = {
      Name        = "iac-apsouth1-rds-mysql"
    }
}
















