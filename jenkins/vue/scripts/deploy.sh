set -x
npm run serve &       # 运行起来
sleep 1               # 睡眠1秒  
echo $! > .pidfile    # 把运行起来的输出到.pidfile文件中
set +x

echo 'Now...'
echo 'visit http://localhost:8080 to see your application in action'