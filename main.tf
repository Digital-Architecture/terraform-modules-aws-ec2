# NTTDATA - DIGITAL ARCHITECTURE
# Create: Marcos Cianci 
# Date: Qua 21 Set 2022
# Terraform Module - AWS EC2

### AWS EC2 ###

resource "aws_instance" "ec2" {

    count                           = var.create_instance && !var.create_instance_spot ? 1 :0 

    ami                             = var.ami
    instance_type                   = var.instance_type

    cpu_core_count                  = var.cpu_core_count
    cpu_threads_per_core            = var.cpu_threads_per_core

    user_data                       = var.user_data
    user_data_base64                = var.user_data_base64

    availability_zone               = var.availability_zone
    subnet_id                       = var.subnet_id
    vpc_security_group_ids          = var.vpc_security_group_ids

    key_name                        = aws_key_pair.key.key_name
    monitoring                      = var.monitoring
    get_password_data               = var.get_password_data
    iam_instance_profile            = var.iam_instance_profile

    associate_public_ip_address     = var.associate_public_ip_address
    private_ip                      = var.private_ip
    secondary_private_ips           = var.secondary_private_ips

    ebs_optimized                   = var.ebs_optimized

    dynamic "root_block_device" {

        for_each = var.root_block_device
        content {
            delete_on_termination   = lookup(root_block_device.value, "delete_on_termination", null)
            encrypted               = lookup(root_block_device.value,"encrypted", null)
            iops                    = lookup(root_block_device.value,"iops", null)
            kms_key_id              = lookup(root_block_device.value,"kms_key_id", null)
            volume_size             = lookup(root_block_device.value,"volume_size", null)
            volume_type             = lookup(root_block_device.value,"volume_type", null)
            throughput              = lookup(root_block_device.value,"throughput", null)
            tags                    = lookup(root_block_device.value,"tags", null)
        }
    }

    dynamic "ebs_block_device" {

        for_each = var.ebs_block_device
        content {
            delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
            device_name           = ebs_block_device.value.device_name
            encrypted             = lookup(ebs_block_device.value, "encrypted", null)
            iops                  = lookup(ebs_block_device.value, "iops", null)
            kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
            snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
            volume_size           = lookup(ebs_block_device.value, "volume_size", null)
            volume_type           = lookup(ebs_block_device.value, "volume_type", null)
            throughput            = lookup(ebs_block_device.value, "throughput", null)
        }
    }

   dynamic "ephemeral_block_device" {

    for_each = var.ephemeral_block_device
    content {
        device_name                 = ephemeral_block_device.value.device_name
        no_device                   = lookup(ephemeral_block_device.value, "no_device", null)
        virtual_name                = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }


    tags = merge({ "Name" = var.ec2_name }, var.tags )
}

### AWS KEY ###

resource "aws_key_pair" "key" {

    key_name    = "${var.ec2_name}${terraform.workspace}"
    public_key  = tls_private_key.tls.public_key_openssh

    tags = {
        Name    = "${var.ec2_name}${terraform.workspace}"
        Env     = terraform.workspace 
    }
}

resource "tls_private_key" "tls" {
    algorithm = "RSA"
}

resource "local_file" "key" {

    content = tls_private_key.tls.private_key_pem
    filename = "${var.ec2_name}${terraform.workspace}.pem"

    provisioner "local-exec" {
        command = "chmod 400 ${var.ec2_name}${terraform.workspace}.pem"
    }
}