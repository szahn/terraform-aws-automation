aws_region        = "us-east-1"
key_name          = "id_rsa_sz"
public_key_path   = "/temp/id_rsa.pub"
dev_instance_type = "t2.micro"
dev_ami		  = "ami-07d0cf3af28718ef8"
cidrs             = {
  public1	  = "10.1.1.0/24"
  public2	  = "10.1.2.0/24"
  private1	  = "10.1.3.0/24"
  private2	  = "10.1.4.0/24"
}
