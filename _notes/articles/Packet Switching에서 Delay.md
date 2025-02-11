
- aws 한국 리전기준 같은 VPC내에서 packet switching에서의 Delay는 어떻게 될까?
- aws 한국 리전기준 다른 VPC내에서 packet switching에서의 Delay는 어떻게 될까?
- 현재 프로젝트 기준으로 ncp의 vpc와 aws 한국 리전 기준 vpc의 데이터베이스의 packet switching에서의 Delay는 어떻게 될까?

- 지금 나의 프로젝트에서 high performance를 방해 하는 요소가 설마 Delay 때문은 아니겠지...
- 생각 해보니까 aws 한국 리전 vpc와 ncp vpc간에서는 하나의 packet switching delay 즉, 하드웨어 통신 장비간의 Delay도 존재하겠네
- CloudWatch에서 하드웨어 통신 장비간의 packet switching Delay 정보를 제공 할리가 없을것 같은데...
- AWS 같은 리전 같은 VPC 간에서도 public subnet , private subnet, AZ등에서도의 Delay도 존재 할 수도 있겠군.
- 백엔드 개발자로 이런거까지 신경 쓰는건 현실성이 좀 떨어지는것 같고 오히려 DNS 캐싱과 TCP 핸드쉐이킹 비용을 최적화 하는게 더 나을것 같기도 하군.