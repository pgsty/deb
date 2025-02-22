#==============================================================#
# File      :   terraform.tf
# Desc      :   5-node oss building env for x86_64/aarch64
# Ctime     :   2024-12-12
# Mtime     :   2025-02-21
# Path      :   tf/terraform
# License   :   AGPLv3 @ https://pigsty.io/docs/about/license
# Copyright :   2018-2025  Ruohang Feng / Vonng (rh@vonng.com)
#==============================================================#


#===========================================================#
# Architecture, Instance Type, OS Images
#===========================================================#
locals {
  bandwidth = 100                       # internet bandwidth in Mbps (100Mbps)
  disk_size = 100                       # system disk size in GB (100GB)
  spot_policy = "SpotWithPriceLimit"    # NoSpot, SpotWithPriceLimit, SpotAsPriceGo
  spot_price_limit = 5                  # only valid when spot_policy is SpotWithPriceLimit
  instance_type_map = {
    amd64 = "ecs.c8i.4xlarge"
    arm64 = "ecs.c8y.4xlarge"
  }
  amd64_instype = local.instance_type_map["amd64"]
  arm64_instype = local.instance_type_map["arm64"]
}

data "alicloud_images" "d12_amd64_img" {
  owners     = "system"
  name_regex = "^debian_12_7_x64"
}
data "alicloud_images" "d12_arm64_img" {
  owners     = "system"
  name_regex = "^debian_12_7_arm64"
}
data "alicloud_images" "u22_amd64_img" {
  owners     = "system"
  name_regex = "^ubuntu_22_04_x64"
}
data "alicloud_images" "u22_arm64_img" {
  owners     = "system"
  name_regex = "^ubuntu_22_04_arm64"
}
data "alicloud_images" "u24_amd64_img" {
  owners     = "system"
  name_regex = "^ubuntu_24_04_x64"
}
data "alicloud_images" "u24_arm64_img" {
  owners     = "system"
  name_regex = "^ubuntu_24_04_arm64"
}


#===========================================================#
# Credentials
#===========================================================#
# add your credentials here or pass them via env
# export ALICLOUD_ACCESS_KEY="????????????????????"
# export ALICLOUD_SECRET_KEY="????????????????????"
# e.g : ./aliyun-key.sh
provider "alicloud" {
  # access_key = "????????????????????"
  # secret_key = "????????????????????"
}


#===========================================================#
# VPC, SWITCH, SECURITY GROUP
#===========================================================#
# use 10.10.10.0/24 cidr block as demo network
resource "alicloud_vpc" "vpc" {
  vpc_name   = "pigsty-net"
  cidr_block = "10.10.10.0/24"
}

# add virtual switch for pigsty demo network
resource "alicloud_vswitch" "vsw" {
  vpc_id     = "${alicloud_vpc.vpc.id}"
  cidr_block = "10.10.10.0/24"
  zone_id    = "cn-beijing-l"
}

# add default security group and allow all tcp traffic
resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = "${alicloud_vpc.vpc.id}"
}
resource "alicloud_security_group_rule" "allow_all_tcp" {
  ip_protocol       = "tcp"
  type              = "ingress"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = "${alicloud_security_group.default.id}"
  cidr_ip           = "0.0.0.0/0"
}




#======================================#
# D12 AMD64
#======================================#
resource "alicloud_instance" "pg-d12" {
  instance_name                 = "pg-d12"
  host_name                     = "pg-d12"
  private_ip                    = "10.10.10.12"
  instance_type                 = local.amd64_instype
  image_id                      = "${data.alicloud_images.d12_amd64_img.images.0.id}"
  vswitch_id                    = "${alicloud_vswitch.vsw.id}"
  security_groups               = ["${alicloud_security_group.default.id}"]
  password                      = "PigstyDemo4"
  instance_charge_type          = "PostPaid"
  internet_charge_type          = "PayByTraffic"
  spot_strategy                 = local.spot_policy
  spot_price_limit              = local.spot_price_limit
  internet_max_bandwidth_out    = local.bandwidth
  system_disk_category          = "cloud_essd"
  system_disk_performance_level = "PL1"
  system_disk_size              = local.disk_size
}

output "d12_ip" {
  value = "${alicloud_instance.pg-d12.public_ip}"
}

#======================================#
# D12 ARM64
#======================================#
resource "alicloud_instance" "pg-d12a" {
  instance_name                 = "pg-d12a"
  host_name                     = "pg-d12a"
  private_ip                    = "10.10.10.112"
  instance_type                 = local.amd64_instype
  image_id                      = "${data.alicloud_images.d12_arm64_img.images.0.id}"
  vswitch_id                    = "${alicloud_vswitch.vsw.id}"
  security_groups               = ["${alicloud_security_group.default.id}"]
  password                      = "PigstyDemo4"
  instance_charge_type          = "PostPaid"
  internet_charge_type          = "PayByTraffic"
  spot_strategy                 = local.spot_policy
  spot_price_limit              = local.spot_price_limit
  internet_max_bandwidth_out    = local.bandwidth
  system_disk_category          = "cloud_essd"
  system_disk_performance_level = "PL1"
  system_disk_size              = local.disk_size
}

output "d12a_ip" {
  value = "${alicloud_instance.pg-d12a.public_ip}"
}



#======================================#
# U22 AMD64
#======================================#
resource "alicloud_instance" "pg-u22" {
  instance_name                 = "pg-u22"
  host_name                     = "pg-u22"
  private_ip                    = "10.10.10.22"
  instance_type                 = local.amd64_instype
  image_id                      = "${data.alicloud_images.u22_amd64_img.images.0.id}"
  vswitch_id                    = "${alicloud_vswitch.vsw.id}"
  security_groups               = ["${alicloud_security_group.default.id}"]
  password                      = "PigstyDemo4"
  instance_charge_type          = "PostPaid"
  internet_charge_type          = "PayByTraffic"
  spot_strategy                 = local.spot_policy
  spot_price_limit              = local.spot_price_limit
  internet_max_bandwidth_out    = local.bandwidth
  system_disk_category          = "cloud_essd"
  system_disk_performance_level = "PL1"
  system_disk_size              = local.disk_size
}

output "u22_ip" {
  value = "${alicloud_instance.pg-u22.public_ip}"
}

#======================================#
# U22 ARM64
#======================================#
resource "alicloud_instance" "pg-u22a" {
  instance_name                 = "pg-u22a"
  host_name                     = "pg-u22a"
  private_ip                    = "10.10.10.122"
  instance_type                 = local.arm64_instype
  image_id                      = "${data.alicloud_images.u22_arm64_img.images.0.id}"
  vswitch_id                    = "${alicloud_vswitch.vsw.id}"
  security_groups               = ["${alicloud_security_group.default.id}"]
  password                      = "PigstyDemo4"
  instance_charge_type          = "PostPaid"
  internet_charge_type          = "PayByTraffic"
  spot_strategy                 = local.spot_policy
  spot_price_limit              = local.spot_price_limit
  internet_max_bandwidth_out    = local.bandwidth
  system_disk_category          = "cloud_essd"
  system_disk_performance_level = "PL1"
  system_disk_size              = local.disk_size
}

output "u22a_ip" {
  value = "${alicloud_instance.pg-u22a.public_ip}"
}



#======================================#
# U22 AMD64
#======================================#
resource "alicloud_instance" "pg-u24" {
  instance_name                 = "pg-u24"
  host_name                     = "pg-u24"
  private_ip                    = "10.10.10.24"
  instance_type                 = local.amd64_instype
  image_id                      = "${data.alicloud_images.u24_amd64_img.images.0.id}"
  vswitch_id                    = "${alicloud_vswitch.vsw.id}"
  security_groups               = ["${alicloud_security_group.default.id}"]
  password                      = "PigstyDemo4"
  instance_charge_type          = "PostPaid"
  internet_charge_type          = "PayByTraffic"
  spot_strategy                 = local.spot_policy
  spot_price_limit              = local.spot_price_limit
  internet_max_bandwidth_out    = local.bandwidth
  system_disk_category          = "cloud_essd"
  system_disk_performance_level = "PL1"
  system_disk_size              = local.disk_size
}

output "u24_ip" {
  value = "${alicloud_instance.pg-u24.public_ip}"
}

#======================================#
# U22 ARM64
#======================================#
resource "alicloud_instance" "pg-u24a" {
  instance_name                 = "pg-u24a"
  host_name                     = "pg-u24a"
  private_ip                    = "10.10.10.124"
  instance_type                 = local.arm64_instype
  image_id                      = "${data.alicloud_images.u24_arm64_img.images.0.id}"
  vswitch_id                    = "${alicloud_vswitch.vsw.id}"
  security_groups               = ["${alicloud_security_group.default.id}"]
  password                      = "PigstyDemo4"
  instance_charge_type          = "PostPaid"
  internet_charge_type          = "PayByTraffic"
  spot_strategy                 = local.spot_policy
  spot_price_limit              = local.spot_price_limit
  internet_max_bandwidth_out    = local.bandwidth
  system_disk_category          = "cloud_essd"
  system_disk_performance_level = "PL1"
  system_disk_size              = local.disk_size
}

output "u24a_ip" {
  value = "${alicloud_instance.pg-u24.public_ip}"
}


# sshpass -p PigstyDemo4 ssh-copy-id el8
# sshpass -p PigstyDemo4 ssh-copy-id el9
# sshpass -p PigstyDemo4 ssh-copy-id el8a
# sshpass -p PigstyDemo4 ssh-copy-id el9a
