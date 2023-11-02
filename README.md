# Hi :wave: intrigued Human!

This is my Terraform Playground.

- I'm recreating Infrastructure that I've created manually before
- next I'll try to refactor my code, so it ll be not as repetetive

---

## Projects:

### [Serverless Messaging Service](./burn2read/README.md)
- This service enables you to leave a password protected & encrypted message for another user.

### [Load-Balancer](./load-balancer/README.md)
- Sets up an Application Load Balancer targeting three NGINX-Servers in three different public Subnets. 

### [SQS-Snailmail](./sqs/README.md)
- Sets up an SQS queue that triggers a Lambda function that creates Cloud Watch Logs.

### [VPC-Peering](./vpc_peering/README.md) 
- Set up 2 VPCs with one public subnet and instance each
- Connect the 2 VPCs via VPC-Peering

### [Full VPC](./full-vpc/README.md)
- Set up a full VPC with private and public subnets, NAT Gateways, and **Jumphosts**