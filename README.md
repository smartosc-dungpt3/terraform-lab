Create 1 VPC, 2 private subnet, 2 public subnet, 2 NAT gateway, 2 EC2, 1 LB

Start localstack:
```
docker run --rm -it -e AWS_DEFAULT_REGION=ap-northeast-1 -e EDGE_PORT=4566 -e AWS_ACCESS_KEY_ID=foobar -e AWS_SECRET_ACCESS_KEY=foobar -p 4566:4566 localstack/localstack:1.3.0
```
