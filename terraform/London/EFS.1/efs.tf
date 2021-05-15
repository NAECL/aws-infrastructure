resource "aws_efs_file_system" "efstest" {
  availability_zone_name = "${local.publicA_AZ}"
  encrypted              = true

  tags = {
    Name = "efstest"
  }
}

resource "aws_efs_mount_target" "efstest" {
  file_system_id  = aws_efs_file_system.efstest.id
  subnet_id       = aws_subnet.PublicA.id
  security_groups = [ aws_security_group.efs_sg.id ]
}
