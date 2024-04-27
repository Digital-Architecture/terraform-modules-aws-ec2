# NTTDATA - DIGITAL ARCHITECTURE
# Create: Marcos Cianci 
# Date: Qua 21 Set 2022
# Terraform Module - AWS EC2


module "ec2" {

    source                  = "../"

    ec2_name                = "teste"
    #iam_instance_profile    = "instance.profile"
    ami                     = "ami-12114i34ui3o4"
    #monitoring              = true 
    #vpc_security_group_ids  = ["sg-0cdkdcldjsnjks"]
    #subnet_id               = "subnet-2eb65362"
    tags                    = {
        name = "teste"
    }
}