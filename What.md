marcos.chat是Marco Song的个人AI分身实验。

我不会复杂的编程和计算机支持，但我了解一点计算机和网络应用，所以我就学习用Vibe Coding的方式做这个实验。我采用的工具是Claude Code。

TA运行在家里一台Jetson Orin 16G设备上面，通过Tailscale获得固定IP连接互联网。

TA运行OpenClaw并由本地Qwen3.5 9B模型支持。

TA运行web server支持公网聊天窗口对话的web访问。域名http://marcos.chat

针对OpenClaw我提供了一些个人信息，并后续逐步开发一些skill，尝试打造自己的AI分身。


UI color theme: 白银为主，土色为辅，点缀深蓝，远离红绿
UI style: learn from https://walkie.sh/


**Requirements**
1. developer will update Persona files on the dev Macbook Air, Persona files needs to be Github synced and always push latest to macos Jetson Orin 16G machine


**About**
Hi, This is Marco's AI companion. He helps Marco to connect with his old or new friends, get mutual updates and arrange meetups. You can ask him anything about Marco.