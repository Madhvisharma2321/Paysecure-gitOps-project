# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "paysecure-rds-sg"
  description = "Allow PostgreSQL access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "paysecure-rds-subnet"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "PaySecure RDS subnet group"
  }
}

# RDS Instance
resource "aws_db_instance" "paysecure_rds" {
  identifier             = "paysecure-rds"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "payments"
  username               = "payuser"
  password               = "paypass123"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "PaySecure-RDS"
  }
}