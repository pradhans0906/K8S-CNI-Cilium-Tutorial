
![(download.jpeg)]


You can find the blog here:


The following is based on the translation of Cilium official website documents。

Current trends
The application system of the modern data center has gradually shifted to a development system based on the micro-service architecture. An application system of the micro-service architecture is composed of multiple small independent services. They communicate through light communication protocols such as HTTP, gRPC, Kafka, etc. 。Services under the micro-service architecture naturally have the characteristics of dynamic changes. Combined with containerized deployment, it often causes large-scale container examples to start or restart。It is both a challenge and an opportunity to ensure the safety of this highly dynamic application of microservices。

Existing problems
The traditional Linux network access security control mechanism (such as iptables) is based on the rules of IP address and port configuration network forwarding and filtering in a static environment, but the IP address is constantly changing and non-fixed under the micro-service architecture; for security purposes, the protocol port (such as the TCP port 80 transmitted by HTTP) is no longer fixed to distinguish application systems。In order to match the rapidly changing life cycle of large-scale container examples, traditional network technologies need to maintain tens of thousands of load balance rules and access control rules, and these rules need to be updated with increasing frequencies, without accurate visualization functions It is also very difficult to maintain these rules, which are a great challenge to the availability and performance of traditional network technologies。For example, there are often people who have a severe performance bottleneck for the kube-proxy iptables-based server balance function under the large-scale container scene. At the same time, due to the very frequent creation and destruction of containers, it is also difficult to achieve identity-based troubleshooting and safety audits based on IP。

solution
As a Kubernetes CNI plug, Cilium was designed for a large-scale and highly dynamic container environment from the beginning, and brought the network security management function of API level perception. By using a new technology based on Linux's internal nuclear characteristics-BPF, Provides service/pod/container as a logo instead of a traditional IP address to define and strengthen the network layer and application layer between the container and Pod strategy。Therefore, Cilium not only simplifies the application of security strategies in a highly dynamic environment, but also provides the third and fourth layer isolation functions of traditional networks, and provides stronger security based on the isolation control on the http layer isolation。

In addition, because BPF can dynamically insert programs that control the Linux system, a powerful security visualization function is achieved, and these changes do not require the application code to be updated or the application service itself can take effect, because BPF is running in the core of the system。
