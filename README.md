# Hi :wave: intrigued Human!

This is my Terraform Playground.

- for now I'm recreating Infrastructure that I've created manually before
- next I'll try to refactor my code, so it ll be not as repetetive

:point_right: Also checkout my great collaborator: [Ramzi Attrous](https://github.com/ramziatrous)


## Projects:

### VPC-Peering :white_check_mark:
- Set up 2 VPCs with one public subnet and instance each
- configure NACL and SG so that:
> - ssh connection is possible from everywhere
> - http & ping is possible only between the peered VPCs

### VPC with private and public SN plus ELB
- set up a VPC with:
> - 2 public subnets
> - 2 private subnets
> - one instance in each private subnet
> - one bastion-host/jump-host in a public subnet
- set up a ELB to balance http-requests between the private instances