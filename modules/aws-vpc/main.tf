# Creating VPC

resource "aws_vpc" "vpc" {
  count = var.enabled ? 1 : 0
  cidr_block           = var.vpc-cidr
  instance_tenancy     = var.instance-tenancy
  enable_dns_support   = var.enable-dns-support
  enable_dns_hostnames = var.enable-dns-hostnames

}

# Creating an Internet Gateway

resource "aws_internet_gateway" "igw" {
  count = var.enabled && length(var.vpc-public-subnet-cidr) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id







}

# Public Subnets

resource "aws_subnet" "public-subnets" {
  count                   = var.enabled && length(var.vpc-public-subnet-cidr) > 0 ? length(var.vpc-public-subnet-cidr) : 0
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  cidr_block              = var.vpc-public-subnet-cidr[count.index]
  vpc_id                  = aws_vpc.vpc[0].id
  map_public_ip_on_launch = var.map_public_ip_on_launch

}

# Public Routes

resource "aws_route_table" "public-routes" {
  vpc_id = aws_vpc.vpc[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
}

# Associate/Link Public-Route With Public-Subnets

resource "aws_route_table_association" "public-association" {
  count          = var.enabled && length(var.vpc-public-subnet-cidr) > 0 ? length(var.vpc-public-subnet-cidr) : 0
  route_table_id = aws_route_table.public-routes.id
  subnet_id      = aws_subnet.public-subnets.*.id[count.index]
}

# Creating Private Subnets

resource "aws_subnet" "private-subnets" {
  count             = var.enabled && length(var.vpc-private-subnet-cidr) > 0 ? length(var.vpc-private-subnet-cidr) : 0
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = var.vpc-private-subnet-cidr[count.index]
  vpc_id            = aws_vpc.vpc[0].id


}

# Elastic IP For NAT-Gate Way

resource "aws_eip" "eip-ngw" {
  count = var.enabled && var.total-nat-gateway-required > 0 ?  var.total-nat-gateway-required : 0
}
# Creating NAT Gateways In Public-Subnets, Each NAT-Gateway Will Be In Diffrent AZ

resource "aws_nat_gateway" "ngw" {
  count         = var.enabled && var.total-nat-gateway-required > 0 ? var.total-nat-gateway-required : 0
  allocation_id = aws_eip.eip-ngw.*.id[count.index]
  subnet_id     = aws_subnet.public-subnets.*.id[count.index]
}

# Private Route-Table For Private-Subnets

resource "aws_route_table" "private-routes" {
  count  = var.enabled && length(var.vpc-private-subnet-cidr) > 0 ? length(var.vpc-private-subnet-cidr) : 0
  vpc_id = aws_vpc.vpc[0].id
  route {
    cidr_block     = var.private-route-cidr
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id,count.index)

}
}

# Associate/Link Private-Routes With Private-Subnets

resource "aws_route_table_association" "private-routes-linking" {
  count          = var.enabled && length(var.vpc-private-subnet-cidr) > 0 ? length(var.vpc-private-subnet-cidr) : 0
  subnet_id      = aws_subnet.private-subnets.*.id[count.index]
  route_table_id = aws_route_table.private-routes.*.id[count.index]
}


##################
# Database subnet
##################
resource "aws_subnet" "database" {
  count = var.create_database_subnet_group && length(var.vpc-database_subnets-cidr) > 0 ? length(var.vpc-database_subnets-cidr) : 0
  cidr_block = var.vpc-database_subnets-cidr[count.index]
  vpc_id = aws_vpc.vpc[0].id
  availability_zone = data.aws_availability_zones.azs.names[count.index]

}



# Database Route-Table For Database-Subnets

resource "aws_route_table" "database-routes" {
  count  = var.create_database_subnet_group && length(var.vpc-database_subnets-cidr) > 0 ? length(var.vpc-database_subnets-cidr) : 0
  vpc_id = aws_vpc.vpc[0].id
  route {
    cidr_block     = var.private-route-cidr
    nat_gateway_id = element(aws_nat_gateway.ngw.*.id,count.index)
}
}


# Associate/Link Database-Routes With Database-Subnets
resource "aws_route_table_association" "database-routes-association" {
  count =  var.create_database_subnet_group && var.create_database_subnet_group && length(var.vpc-database_subnets-cidr) > 0 ? length(var.vpc-database_subnets-cidr) : 0
  subnet_id = element(aws_subnet.database.*.id,count.index )
  route_table_id = element(aws_route_table.database-routes.*.id,count.index )
}
